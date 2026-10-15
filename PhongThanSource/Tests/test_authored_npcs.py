import importlib.util
import hashlib
import json
import sys
import unittest
from pathlib import Path

ROOT=Path(__file__).parents[1]
sys.path.insert(0,str(ROOT/'Tools'))
from build_authored_npcs import guide_lua,place_in_tile,blocked,quote
from prepare_npc_restoration import npc_records,split_region

class AuthoredTests(unittest.TestCase):
    def test_profiles_cover_all_126_without_default_generic_profile(self):
        profiles=json.loads((ROOT/'Deploy/ProjectContent/NpcRestoration/authored_profiles.json').read_text('utf8'))
        audit=json.loads((ROOT/'Docs/NPC_CAMPAIGN_126_AUDIT.json').read_text('utf8'))
        self.assertEqual(len(audit['rows']),126)
        for n in audit['rows']:
            archetype,guide,source=profiles['profiles'][n['name']]
            self.assertIn(archetype,profiles['archetypes'])
            self.assertIn(source,profiles['source_urls'])
            self.assertGreater(len(guide),50)

    def test_authored_only_lua_cannot_mutate_currency_inventory_or_quests(self):
        n=dict(key='1002_01',world=1002,name='To Ho',map_name='Sung Thanh',x=200,y=204,role_guide='Huong dan rieng cua To Ho')
        script=guide_lua(n,[],None)
        for token in (b'AddItem',b'DelItem',b'Pay(',b'SetTask',b'NewWorld',b'AddOwnExp',b'Include',b'Sale('):
            self.assertNotIn(token,script)
        self.assertIn(b'local w = GetWorldPos()',script)
        self.assertIn(b'pt_guard()',script)

    def test_authored_vietnamese_menu_uses_tcvn3_lua_byte_escapes(self):
        # An authored message is encoded as single-byte TCVN3 when Lua
        # evaluates \ddd. The client has no UTF-8 text decoder.
        self.assertEqual(quote('Đóng/pt_close'), '"\\167\\227ng/pt_close"')
        self.assertEqual(quote('Lão Rùa'), '"L\\183o R\\239a"')
        with self.assertRaisesRegex(ValueError, 'Unsupported TCVN3 glyph'):
            quote('emoji 😀')
        base=dict(key='1004_11', world=1004, name='Lao Rua',
                  map_name='Xi Vuu Mo', x=200, y=202,
                  role_guide='Dau moi Lao Rua duoc tai dung')
        script=guide_lua(base, [], None)
        self.assertTrue(script.isascii())
        self.assertIn(quote('Vai trò và hướng dẫn/pt_about').encode('ascii'), script)
        self.assertIn(quote('NPC liên quan/pt_routes').encode('ascii'), script)
        self.assertIn(quote('Trạng thái chức năng/pt_status').encode('ascii'), script)
        self.assertIn(quote('Đóng/pt_close').encode('ascii'), script)
        self.assertIn(quote('Lão Rùa - Xi Vưu Mộ (200/202)').encode('ascii'), script)
        self.assertNotIn(b'Vai tro va huong dan', script)
        self.assertNotIn('Lão Rùa'.encode('utf8'), script)
        self.assertNotIn(b'AddItem(', script)

    def test_lao_rua_compiled_scripts_match_generator_and_manifest(self):
        report=json.loads((ROOT/'Docs/NPC_RESTORATION_DEPLOYMENT.json').read_text('utf8'))
        catalog=json.loads((ROOT/'Deploy/ProjectContent/NpcRestoration/coordinates.json').read_text('utf8'))
        bykey={r['key']:r for r in report['rows']}
        for key in ('1002_19','1003_11','1004_11'):
            n=bykey[key]
            peers=[dict(name=p[0], x=p[2], y=p[3]) for p in catalog['maps'][str(n['world'])]]
            generated=guide_lua(n, peers, None)
            path=ROOT/'Deploy/ProjectContent/NpcRestoration/compiled'/n['lua']['relative']
            published=path.read_bytes()
            self.assertEqual(generated, published, f'Stale compiled Lua: {key}')
            self.assertEqual(hashlib.sha256(published).hexdigest(), n['lua']['sha256'])
            self.assertEqual(len(published), n['lua']['bytes'])
            self.assertIn(quote('Quay lại/main').encode('ascii'), published)
            self.assertIn(quote('Đóng/pt_close').encode('ascii'), published)
            staged=ROOT.parent/'PhongThanRuntime-Staging/Server'/n['lua']['relative']
            self.assertEqual(staged.read_bytes(), published)
            entry=next(p for p in report['scripts'] if p['relative']==n['lua']['relative'])
            self.assertEqual(entry['sha256'], n['lua']['sha256'])
            self.assertEqual(entry['bytes'], len(published))

    def test_static_npc_sync_is_sent_on_initial_entry(self):
        source=(ROOT/'Sources/Core/Src/KPlayer.cpp').read_bytes()
        start=source.index(b'KPlayer::LaunchPlayer()')
        body=source[start:source.index(b'BOOL\tKPlayer::ExecuteScript',start)]
        self.assertIn(b'SyncNpcNearPlayer(m_nPlayerIndex)',body)

    def test_published_set_preserves_previous_11_and_has_no_duplicate_records(self):
        report=json.loads((ROOT/'Docs/NPC_RESTORATION_DEPLOYMENT.json').read_text('utf8'))
        self.assertEqual(report['authored_scripts'],126)
        self.assertEqual(sum(n.get('authored') is False for n in report['rows'] if n['status']=='READY'),11)
        self.assertEqual(report['pending'],1) # explicit outside-WOR Bia Than, never fabricated
        for n in report['rows']:
            if n.get('authored') and n.get('original_name') and n['original_name']!='修行师':
                self.assertEqual(n['record_name'],n['original_name'])
        keys=set()
        for row in report['overrides']:
            b=(ROOT/'Deploy/ProjectContent/NpcRestoration/compiled'/row['relative']).read_bytes()
            payload=split_region(b)[2] if row['relative'].endswith('_region_s.dat') else b
            for record in npc_records(payload):
                k=(row['relative'],record)
                self.assertNotIn(k,keys);keys.add(k)

if __name__=='__main__':unittest.main()
