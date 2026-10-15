"""Build the user-approved complete authored NPC population as one batch.

Original geometry and PAKs are read-only. The output uses the existing NPC
section loader. Authored guides are not mislabeled as implemented quest rewards.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
import struct
import subprocess
import sys
from pathlib import Path
from prepare_npc_restoration import PakReader, rows, disk_path, split_region, npc_records, merge_region, standalone_npcs

PROJECT = Path(__file__).resolve().parents[1]
BASE = PROJECT.parent
OUT = PROJECT / 'Deploy/ProjectContent/NpcRestoration/compiled'


# These are the original one-byte TCVN3 glyph slots used by the VNG ASF
# bitmap fonts. The authored Lua source stays ASCII by using Lua \ddd escapes;
# the Lua VM emits actual TCVN3 bytes to the legacy game client.
_TCVN_BYTES = bytes.fromhex(
    'B5 B8 B6 B7 B9 A8 BB BE BC BD C6 A9 C7 CA C8 C9 CB AE CC D0 CE CF D1 AA '
    'D2 D5 D3 D4 D6 D7 DD D8 DC DE DF E3 E1 E2 E4 AB E5 E8 E6 E7 E9 AC EA ED '
    'EB EC EE EF F3 F1 F2 F4 AD F5 F8 F6 F7 F9 FA FD FB FC FE A1 A2 A7 A3 A4 A5 A6'
)
_TCVN_POINTS = tuple(int(x, 16) for x in (
    'E0 E1 1EA3 E3 1EA1 103 1EB1 1EAF 1EB3 1EB5 1EB7 E2 1EA7 1EA5 1EA9 '
    '1EAB 1EAD 111 E8 E9 1EBB 1EBD 1EB9 EA 1EC1 1EBF 1EC3 1EC5 1EC7 EC '
    'ED 1EC9 129 1ECB F2 F3 1ECF F5 1ECD F4 1ED3 1ED1 1ED5 1ED7 1ED9 '
    '1A1 1EDD 1EDB 1EDF 1EE1 1EE3 F9 FA 1EE7 169 1EE5 1B0 1EEB 1EE9 '
    '1EED 1EEF 1EF1 1EF3 FD 1EF7 1EF9 1EF5 102 C2 110 CA D4 1A0 1AF'
).split())
assert len(_TCVN_BYTES) == len(_TCVN_POINTS)
_TCVN_MAP = {chr(cp): byte for cp, byte in zip(_TCVN_POINTS, _TCVN_BYTES)}

# These are display strings only. Keep the ASCII source identifiers/record_name,
# Lua callback paths, world IDs and original VNG/Pak payloads unchanged.
_NPC_DISPLAY = {
    'Lao Rua': 'Lão Rùa',
    'Thuong Nhan Tay Vuc': 'Thương Nhân Tây Vực',
    'Sinh Hoat Su': 'Sinh Hoạt Sư',
    'Thieu Hao': 'Thiếu Hạo',
    'Hau Tho': 'Hậu Thổ',
    'Chuyen Sinh Lao Lao': 'Chuyển Sinh Lão Lão',
    'Thu Kho': 'Thủ Kho',
    'Tan Thu Thi Luyen': 'Tân Thủ Thí Luyện',
    'Au Thien Hoa': 'Âu Thiên Hóa',
}
_MAP_DISPLAY = {
    'Xi Vuu Mo': 'Xi Vưu Mộ',
    'Sung Thanh doanh': 'Sùng Thành Doanh',
    'Ngoc Hu cung': 'Ngọc Hư Cung',
}
_ROLE_DISPLAY = {
    'Lao Rua': ('Đầu mối Lão Rùa được tái dựng theo danh mục đã duyệt. '
                'Có thể hỏi địa chỉ và tra cứu những NPC liên quan trong bản đồ.'),
}


def quote(text):
    """Return a quoted, ASCII-only Lua string emitting single-byte TCVN3.

    ASCII callback names and '/' delimiters remain unchanged. Reject any
    unsupported glyph rather than silently strip accents or emit UTF-8.
    """
    out = []
    for char in text:
        code = ord(char)
        if char == '\\':
            out.append('\\\\')
        elif char == '"':
            out.append('\\"')
        elif char == '\n':
            out.append('\\n')
        elif code < 32:
            raise ValueError(f'Unsupported control code: {code}')
        elif code < 128:
            out.append(char)
        elif char in _TCVN_MAP:
            out.append('\\%03d' % _TCVN_MAP[char])
        else:
            raise ValueError(f'Unsupported TCVN3 glyph: U+{code:04X}')
    return '"' + ''.join(out) + '"'


def guide_lua(npc, peers, original):
    """One state per NPC script; copied original callbacks retain their scope.

    No Include() because that legacy API bypasses PAK. An original source
    payload is retained exactly before an explicit authored menu wrapper.
    """
    nearby=sorted((p for p in peers if p['name']!=npc['name']),
                  key=lambda p:(p['x']-npc['x'])**2+(p['y']-npc['y'])**2)[:5]
    routes='; '.join(f"{_NPC_DISPLAY.get(p['name'], p['name'])} ({p['x']}/{p['y']})" for p in nearby) or 'Không có NPC khác trong danh mục bản đồ này.'
    status=('Có nhánh Lua VNG gốc trong PAK. Các điều kiện và giao dịch do nhánh gốc kiểm tra; chưa nghiệm thu toàn bộ nhiệm vụ.'
            if original else 'Đang mở: đối thoại, hướng dẫn và tra cứu. Nhận/trả nhiệm vụ, đổi thưởng và giao dịch chưa mở khi chưa đủ mã dữ liệu.')
    prefix = b''
    if original:
        patch=b''
        if npc.get('quest_appendix'):
            patch=b'\n-- Reviewed project quest transaction compatibility.\n'+npc['quest_appendix']
        prefix=(b'-- Original VNG source payload; provenance in deployment report.\n'+original+patch+
                b'\npt_original_main = main\n-- Authored restoration menu begins here.\n')
    options=[quote('Vai trò và hướng dẫn/pt_about'),quote('NPC liên quan/pt_routes'),quote('Trạng thái chức năng/pt_status')]
    if original:options.append(quote('Chức năng VNG gốc/pt_original'))
    options.append(quote('Đóng/pt_close'))
    text=f'''-- AUTHORED NPC {npc['key']}; not a claim of original appearance.
function pt_guard()
    local w = GetWorldPos()
    if w ~= {npc['world']} then CloseDialog(); return 0 end
    return 1
end
function main()
    if pt_guard() == 0 then return end
    Say({quote(_NPC_DISPLAY.get(npc['name'], npc['name'])+' - '+_MAP_DISPLAY.get(npc['map_name'], npc['map_name'])+' ('+str(npc['x'])+'/'+str(npc['y'])+')')}, {len(options)}, {', '.join(options)})
end
function pt_about()
    if pt_guard() == 0 then return end
    Say({quote(_ROLE_DISPLAY.get(npc['name'], npc['role_guide']))}, 2, {quote('Quay lại/main')}, {quote('Đóng/pt_close')})
end
function pt_routes()
    if pt_guard() == 0 then return end
    Say({quote(routes)}, 2, {quote('Quay lại/main')}, {quote('Đóng/pt_close')})
end
function pt_status()
    if pt_guard() == 0 then return end
    Say({quote(status)}, 2, {quote('Quay lại/main')}, {quote('Đóng/pt_close')})
end
function pt_close()
    CloseDialog()
end
'''
    if original:
        text+='function pt_original()\n    if pt_guard() == 0 then return end\n    pt_original_main()\nend\n'
    return prefix+text.encode('ascii')


def barrier_at(data, x, y):
    head, sections, _=split_region(data)
    off,size=sections[0]
    if size==0:return 0
    if size!=2048:raise ValueError(f'Unknown obstruction length {size}')
    return struct.unpack_from('<I',data,head+off+4*((x%512//32)*32+(y%1024//32)))[0]


def blocked(flag,x,y):
    code,shape=flag&15,(flag>>4)&15
    ox,oy=x%32,y%32
    free=((shape==2 and ox+oy>32) or (shape==3 and ox<oy) or
          (shape==4 and ox>oy) or (shape==5 and ox+oy<32))
    return bool(code and not free)


def place_in_tile(data,x,y,occupied):
    """Choose a walkable subcell without changing the accepted displayed X/Y."""
    candidates=[(x,y)]+[(x//256*256+dx,y//512*512+dy)
                        for dx in range(16,256,32) for dy in range(16,512,32)]
    candidates.sort(key=lambda p:(p[0]-x)**2+(p[1]-y)**2)
    for px,py in candidates:
        if not blocked(barrier_at(data,px,py),px,py) and all(abs(px-ox)>32 or abs(py-oy)>32 for ox,oy in occupied):
            return px,py
    raise ValueError('No safe point within accepted displayed coordinate')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true')
    args=parser.parse_args()
    catalog=json.loads((PROJECT/'Deploy/ProjectContent/NpcRestoration/coordinates.json').read_text('utf8'))
    profiles=json.loads((PROJECT/'Deploy/ProjectContent/NpcRestoration/authored_profiles.json').read_text('utf8'))
    audit=json.loads((PROJECT/'Docs/NPC_CAMPAIGN_126_AUDIT.json').read_text('utf8'))
    # Recalculate the unmodified verified baseline in memory, never from Output.
    result=subprocess.run([sys.executable,str(PROJECT/'Tools/prepare_npc_restoration.py')],capture_output=True,check=True)
    baseline=json.loads(result.stdout.decode('utf8'))
    bykey={(n['world'],n['name']):n for n in baseline['rows']}
    intended={(n['world'],n['name']) for n in audit['rows']}
    if len(intended)!=126:raise ValueError('The approved batch must contain exactly 126 distinct NPC rows')
    source=BASE/'PhongThanRuntime-Content/Server'
    reader=PakReader(BASE/'PhongThanRuntime-Content/Client',BASE/'SeaweedUnpack_SprView/SeaweedUnpack_SprView/UnpackCore.dll')
    try:
        tab=rows(reader.get('settings/Npcs.txt')[0]);header=tab[0];templates=tab[1:]
        kinds={r[0].decode('gbk'):r for r in rows(reader.get('settings/npcres/人物类型.txt')[0])[1:]}
        sprites={r[0].decode('gbk'):r for r in rows(reader.get('settings/npcres/普通npc资源.txt')[0])[1:]}
        worldtext=(source/'settings/WorldSet.ini').read_bytes().decode('gbk')
        worlds=dict(re.findall(r'^(\d+)=([^\r\n]+)',worldtext,re.M))
        labels=dict(re.findall(r'^(\d+)_name=([^\r\n]+)',worldtext,re.M))
        allrows=[];files={};groups={};issues=[];occupied={}
        for world,items in catalog['maps'].items():
            for index,(vn,cn,x,y,note) in enumerate(items):
                old=bykey[int(world),vn]
                if old['status']=='EXISTING_PAK':allrows.append(old);continue
                authored=(int(world),vn) in intended
                if authored:
                    if vn not in profiles['profiles']:raise ValueError(f'Missing deliberate profile for {vn}')
                    archetype,guide,source_key=profiles['profiles'][vn]
                    candidates=[r for r in audit['placement_references'] if r['world']==int(world) and r['name']==cn]
                    alias=profiles['logical_aliases'].get(f'{world}:{vn}')
                    if alias:
                        cn,lua_path,tid=alias;identity='AUTHORED_LOGICAL_ALIAS';identity_proof={'rule':alias}
                    elif candidates:
                        candidates.sort(key=lambda n:n['evidence']['source_kind']!='ACTIVE_VNG_CHAIN')
                        chosen=candidates[0];tid=chosen['template'];lua_path=chosen['script'];identity='REFERENCE_RECONSTRUCTION';identity_proof=chosen
                    elif old.get('template') is not None:
                        tid=old['template'];lua_path=old.get('lua_candidate') or old.get('lua',{}).get('logical','');identity='NAMED_TEMPLATE_RECONSTRUCTION';identity_proof={'prior_reasons':old['reasons']}
                    else:
                        tid,why=profiles['archetypes'][archetype];lua_path=old.get('lua_candidate') or old.get('lua',{}).get('logical','');identity='AUTHORED_VNG_ARCHETYPE';identity_proof={'archetype':archetype,'reason':why}
                    row=templates[tid]
                    if row[1]!=b'3':raise ValueError(f'Not a dialog NPC template: {tid}')
                    if len(row)!=len(header) or row[header.index(b'TimerScript')]:raise ValueError(f'Unsafe timed/ambiguous template {tid}')
                    logical = '\\'+lua_path.lstrip('\\') if lua_path else ''
                    original=reader.get(logical) if logical else None
                    if original and (not re.search(rb'function\s+main\s*\(',original[0]) or re.search(rb'\bInclude\s*\(',original[0])):
                        original=None # no hidden missing dependency; authored guide remains available
                    key=f'{world}_{index:02d}'
                    n=dict(world=int(world),name=vn,original_name=cn,x=x,y=y,note=note,key=key,
                           template=tid,authored=True,identity_basis=identity,identity_evidence=identity_proof,
                           archetype=archetype,role_guide=guide,rule_source=profiles['source_urls'][source_key],
                           map_name=labels[world].split(' - ',1)[-1],status='READY',reasons=[],
                           full_business_logic_verified=False)
                    script_logical=f'\\script\\phongthan\\npc_restore\\{key}.lua'
                    n['lua_original']=original[1] if original else None
                    n['lua_status']='AUTHORED_GUIDE_WITH_ORIGINAL_BRANCH' if original else 'AUTHORED_GUIDE_RULES_NOT_TRANSACTIONAL'
                    peers=[dict(name=v[0],x=v[2],y=v[3]) for v in items]
                    if key=='1002_00' and original:
                        expected='c44b9f6b28692d77a4a4c6f51d35ebb6a509241e0be102d7b7c78eb4b026460c'
                        if original[1]['sha256']!=expected:raise ValueError('To Ho quest source changed; review appendix before rebuilding')
                        appendix=PROJECT/'Deploy/ProjectContent/NpcRestoration/quest_overrides/to_ho_task20.lua'
                        raw=appendix.read_bytes();n['quest_appendix']=raw
                        n['quest_compatibility']={'task':20,'patch':str(appendix.relative_to(PROJECT)),
                            'source_sha256':expected,'patch_sha256':hashlib.sha256(raw).hexdigest(),
                            'status':'LUA_AND_TRANSACTION_TESTED_NOT_LIVE_ACCEPTED'}
                    lua=guide_lua(n,peers,original[0] if original else None)
                    n.pop('quest_appendix',None)
                    relative=script_logical.lstrip('\\').replace('\\','/')
                    files[relative]=lua
                    n['lua']={'logical':script_logical,'sha256':hashlib.sha256(lua).hexdigest(),'relative':relative,'bytes':len(lua)}
                    # Keep the original script identity where known. Ambiguous
                    # camp labels need distinct names; translations stay wire-only.
                    n['record_name']=cn if cn and cn!='修行师' else vn
                else:
                    n=dict(old);n['authored']=False;n['record_name']=old['original_name'];tid=n['template'];row=templates[tid]
                res=row[12].decode('gbk');n['npc_res_type']=res
                if res not in kinds or res not in sprites:raise ValueError(f'Missing SPR mapping {res}')
                spr=kinds[res][2].decode('gbk').rstrip('\\')+'\\'+sprites[res][1].decode('gbk')
                resource=reader.get(spr)
                if not resource:raise ValueError(f'SPR not found in priority PAK: {spr}')
                n['spr']=resource[1]
                # Frozen published coordinates for 11 known entries; all new
                # website positions use the center of their accepted display tile.
                wx,wy=(old['world_x'],old['world_y']) if not authored else (x*256+128,y*512+256)
                n.update(world_x=wx,world_y=wy,region_x=wx//512,region_y=wy//1024,local_x=wx%512,local_y=wy%1024)
                bounds_file=disk_path(source,f'maps\\{worlds[world]}.wor')
                if not bounds_file.exists():issues.append({'npc':vn,'world':world,'error':'MISSING_WOR'});allrows.append(n);continue
                bounds=re.search(rb'(?im)^rect\s*=\s*(\d+),(\d+),(\d+),(\d+)',bounds_file.read_bytes())
                if not bounds:raise ValueError('Missing WOR bounds')
                l,t,r,b=map(int,bounds.groups());rx,ry=wx//512,wy//1024
                if not (l<=rx<=r and t<=ry<=b):issues.append({'npc':vn,'world':world,'error':'OUTSIDE_WOR','position':[rx,ry],'bounds':[l,t,r,b]});allrows.append(n);continue
                logical_region=f'maps\\{worlds[world]}_S\\v_{ry:03d}\\{rx:03d}_region_s.dat'
                p=disk_path(source,logical_region)
                basepak=reader.get(logical_region)
                base=basepak[0] if basepak else (p.read_bytes() if p.exists() else None)
                if base is None:
                    alternate=reader.get(logical_region.replace(worlds[world]+'_S',worlds[world]));base=alternate[0] if alternate else None
                cl=reader.get(f'maps\\{worlds[world]}\\v_{ry:03d}\\{rx:03d}_region_c.dat')
                if not cl:
                    cf=disk_path(BASE/'PhongThanRuntime-Content/Client',f'maps\\{worlds[world]}\\v_{ry:03d}\\{rx:03d}_region_c.dat')
                    if cf.exists():cl=(cf.read_bytes(),{'source':str(cf),'kind':'runtime_client_geometry'})
                if base is None and cl is None:issues.append({'npc':vn,'world':world,'error':'NO_GEOMETRY_CELL','position':[rx,ry]});allrows.append(n);continue
                geometry=base if base is not None else cl[0]
                occ=occupied.setdefault(world,[])
                if authored:
                    ox,oy=wx,wy
                    try:wx,wy=place_in_tile(geometry,wx,wy,occ)
                    except ValueError as e:issues.append({'npc':vn,'world':world,'error':str(e)});allrows.append(n);continue
                    if (wx,wy)!=(ox,oy):n['subcell_adjustment']={'from':[ox,oy],'to':[wx,wy],'display_coordinate_unchanged':True}
                    n.update(world_x=wx,world_y=wy,local_x=wx%512,local_y=wy%1024)
                occ.append((wx,wy))
                n['barrier_cell']=barrier_at(geometry,wx,wy)
                script=n['lua']['logical'].encode('gbk');name=n['record_name'].encode('gbk')
                if len(name)>31 or len(script)>127:raise ValueError(f'Record exceeds byte limits: {vn}')
                record=struct.pack('<iiiB3x32shhhhBBH',tid,wx,wy,0,name,1,0,0,3,int(row[2] or 0),int(row[3] or 0),len(script))+script
                suffix='region_s' if base is not None else 'npc_s'
                relative=f'settings/phongthan/npc_regions/{world}/v_{ry:03d}/{rx:03d}_{suffix}.dat'
                n['override']=relative
                plan=groups.setdefault(relative,{'base':base,'records':[],'source':str(p) if base is not None else None})
                plan['records'].append(record);allrows.append(n)
        report=dict(schema=2,scope='USER_APPROVED_ALL_126_RECONSTRUCTION',rows=allrows,issues=issues,
                    ready=sum('override' in n for n in allrows),pending=len(issues),existing_web_matches=6,
                    authored_requested=126,authored_scripts=len([p for p in files if p.endswith('.lua')]),
                    original_npcs=38,original_monsters=1183,full_business_logic_verified=False,
                    complete=not issues,visual_acceptance=False,overrides=[],scripts=[])
        for relative,plan in groups.items():
            data=merge_region(plan['base'],plan['records']) if plan['base'] is not None else standalone_npcs(plan['records'])
            files[relative]=data
            report['overrides'].append({'relative':relative,'sha256':hashlib.sha256(data).hexdigest(),'added':len(plan['records']),
                                       'base':plan['source'],'base_sha256':hashlib.sha256(plan['base']).hexdigest() if plan['base'] else None})
        # Display original labels for pre-existing verified entries; authored
        # records already contain single-byte Vietnamese transliterations.
        names={n['record_name']:n['name'] for n in allrows if n['status']=='READY'}
        files['settings/phongthan/NpcDisplayNames.txt']=b'Name\tDisplayName\r\n'+b''.join(k.encode('gbk')+b'\t'+v.encode('ascii')+b'\r\n' for k,v in sorted(names.items()))
        for path,data in files.items():
            if path.endswith('.lua'):report['scripts'].append({'relative':path,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)})
        report['population_complete']=not issues
        report['all_scripts_authored']=report['authored_scripts']==126
        for issue in issues:
            for n in allrows:
                if n['world']==int(issue['world']) and n['name']==issue['npc']:
                    n['status']='BLOCKED_GEOMETRY';n['reasons']=[issue['error']]
        if args.write:
            # Publish the complete safe set once; retain an explicit blocker
            # instead of inventing geometry or falsely reporting all spawned.
            unexpected=[i for i in issues if i['error']!='OUTSIDE_WOR']
            if unexpected:raise ValueError('UNSAFE_BATCH_REFUSED: '+json.dumps(unexpected,ensure_ascii=False))
            for relative,data in files.items():
                dest=OUT/relative;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
            (PROJECT/'Docs/NPC_RESTORATION_DEPLOYMENT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n','utf8')
            spr_paths=sorted({n['spr']['logical'] for n in allrows if n['status']=='READY'})
            (PROJECT/'Docs/NPC_RESTORATION_SPR_PATHS.txt').write_bytes(('\r\n'.join(spr_paths)+'\r\n').encode('gbk'))
            lua_paths=[p.replace('/','\\') for p in files if p.endswith('.lua')]
            (PROJECT/'Docs/NPC_RESTORATION_LUA_PATHS.txt').write_bytes(('\r\n'.join(lua_paths)+'\r\n').encode('ascii'))
        print(json.dumps(report,ensure_ascii=False,indent=2))
    finally:reader.close()


if __name__=='__main__':
    sys.stdout.reconfigure(encoding='utf8');main()
