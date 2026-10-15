'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const root=path.join(__dirname,'..');
const html=fs.readFileSync(path.join(root,'AdminWeb/index.html'),'utf8');
const ps=fs.readFileSync(path.join(root,'AdminWeb/PhongThan-Admin.ps1'),'utf8');
const ini=fs.readFileSync(path.join(root,'PhongThanRuntime-Staging/Client/Ui/Setting.ini'));
const script=(html.match(/<script>([\s\S]*?)<\/script>/)||[])[1];
assert.ok(script,'Admin UI script missing');

const localeRaw=fs.readFileSync(path.join(root,'AdminWeb/locales/vi-VN.json'),'utf8');
const locale=JSON.parse(localeRaw);
const renderedScript=script.replace('__PT_LOCALE_JSON__',JSON.stringify(locale));
const start=renderedScript.indexOf('const PT_LOCALE=');
const end=renderedScript.indexOf('async function api(path,body)',start);
assert.ok(start>=0&&end>start,'Shared locale binding is missing');
const context=vm.createContext({});
vm.runInContext(renderedScript.slice(start,end)+'\nthis.ptViMessage=ptViMessage;this.map=PT_VI_MESSAGES;',context);
const tr=context.ptViMessage;

test('HTML uses Vietnamese workspace labels and UTF-8, while API contracts remain unchanged',()=>{
  assert.match(html,/<html lang="vi">/);
  assert.match(html,/<meta charset="utf-8">/);
  assert.match(html,/>TRUNG TÂM QUẢN TRỊ<\/small>/);
  assert.match(html,/>Danh mục<\/button>/);
  assert.match(html,/TỔNG QUAN \/ QUẢN TRỊ/);
  assert.match(html,/Cấp mới \(1–200\)/);
  assert.ok(!html.includes('>CONTROL CENTER<'));
  assert.ok(!html.includes('Level mới'));
  assert.doesNotThrow(()=>new vm.Script(script,{filename:'AdminWeb inline JS'}));
  assert.match(script,/\bptViMessage\(h\.desc\)/);
  assert.match(script,/\bptViMessage\(h\.detail\)/);
  assert.match(script,/j\.message=ptViMessage\(j\.message\)/);
  assert.match(script,/ptViMessage\(j\.error\|\|/);
  assert.match(script,/problems\.slice\(0,2\)\.map\(ptViMessage\)/);
  assert.match(script,/const PT_LOCALE=__PT_LOCALE_JSON__;/);
  assert.ok(!script.includes('const PT_VI_MESSAGES={'),'There must be no duplicated hard-coded translations in HTML');
  assert.equal(locale.locale,'vi-VN');
  assert.ok(Object.keys(locale.messages).length>=50);
  assert.ok(locale.patterns.length>=20);
  assert.match(script,/'X-PT-Token':TOKEN/);
});

test('Vietnamese UI messages from ASCII-only PowerShell errors are translated',()=>{
  assert.equal(tr('Khong tim thay tai khoan.'),'Không tìm thấy tài khoản.');
  assert.equal(tr('Phai khong hop le.'),'Hệ phái không hợp lệ.');
  assert.equal(tr('Chua chon ky nang nao cua phai nay.'),'Chưa chọn kỹ năng nào của hệ phái này.');
  assert.equal(tr('Sai token. Tai lai trang.'),'Phiên quản trị không hợp lệ. Vui lòng tải lại trang.');
  assert.equal(tr('Khong tim thay vat pham MagicScript|5624'),'Không tìm thấy vật phẩm MagicScript|5624');
  assert.equal(tr('Da luu su kien '+"'Lễ hội'"+'.'),"Đã lưu sự kiện 'Lễ hội'.");
  assert.equal(tr('Da xep lenh 12: phat do'),'Đã xếp lệnh 12: phat do');
  assert.equal(tr('Ban do 98 khong co trong danh sach ban do cua server.'),'Bản đồ 98 không có trong danh sách bản đồ của server.');
  assert.match(tr('Bang vat pham chua duoc xac minh voi PAK. Chuc nang phat vat pham da bi khoa de tranh sai item ID; chay AdminWeb\\Install-Pak-Extractor.cmd de xac minh 15 bang PAK va khoi dong lai Web Admin.'),/^Bảng vật phẩm chưa được xác minh/);
  const missingTool='Thieu PakEntryExtract.exe tai C:\\Game\\AdminWeb\\bin\\PakEntryExtract.exe. Chay AdminWeb\\Install-Pak-Extractor.cmd, sau do khoi dong lai Web Admin.';
  const localizedTool=tr(missingTool);
  assert.match(localizedTool,/^Thiếu PakEntryExtract.exe tại /);
  assert.ok(localizedTool.includes('AdminWeb\\Install-Pak-Extractor.cmd'),'Display installation path must preserve Windows backslash');
  assert.equal(tr('Khong trich duoc armor.txt tu PAK va khong co bang loose: C:\\Game\\armor.txt'), 'Không trích xuất được armor.txt từ PAK và không có bảng dự phòng: C:\\Game\\armor.txt');
  assert.ok(Object.keys(context.map).length>=40,'Maintain complete, centralized Vietnamese UI translations');
});

test('unknown game data, account identifiers, paths and payload values are not rewritten',()=>{
  for(const value of ['role_01.pthc','MagicScript|5624','Đạo Sĩ','SERVER_READY','Client\\config.ini','potion_v2','world_map_id_102']){
    assert.equal(tr(value),value);
  }
  assert.equal(tr(null),null);
  assert.equal(tr(53),53);
  assert.ok([...ps].every(ch=>ch.codePointAt(0)<128),'PowerShell 5.1 source deliberately keeps ASCII to prevent active codepage corruption');
  assert.ok(!localeRaw.charCodeAt(0)===0xfeff || !localeRaw.startsWith('\ufeff'));
  assert.match(ps,/Import-PtAdminLocale \$UiLocalePath/);
  assert.match(ps,/ConvertTo-PtLocalizedJson \$json/);
  assert.match(ps,/Replace\('__PT_LOCALE_JSON__'/);
  assert.ok(!ps.includes('Get-Content -Raw -Encoding Default'));
});

function parseTcvnMap(variable){
  const m=ps.match(new RegExp('\\$'+variable+' = @\\(([^)]+)\\)'));
  assert.ok(m,'TCVN3 mapping not found: '+variable);
  return m[1].split(',').map(x=>parseInt(x.trim(),16));
}
const from=parseTcvnMap('tcvnFrom'),to=parseTcvnMap('tcvnTo');
const charToByte=new Map(to.map((c,i)=>[c,from[i]]));
function encodeLegacy(str){
  return Buffer.from(Array.from(str,letter=>{
    const cp=letter.codePointAt(0);
    if(cp<128)return cp;
    assert.ok(charToByte.has(cp),'Unrepresentable TCVN3 glyph: '+letter);
    return charToByte.get(cp);
  }));
}
test('original Client exit message uses single-byte TCVN3, never UTF-8',()=>{
  const correct=encodeLegacy('22=Bạn có muốn thoát khỏi Phong Thần Online?');
  assert.ok(ini.includes(correct),'Expected exact legacy TCVN3 exit prompt');
  assert.ok(!ini.includes(Buffer.from('22=Ban co muon thoat khoi Phong Than Online?')));
  assert.ok(!ini.includes(Buffer.from('22=Bạn có muốn thoát khỏi Phong Thần Online?','utf8')));
  assert.ok(ini.includes(Buffer.from([0x30,0x5f,0x4e,0x61,0x6d,0x65,0x3d])),'Existing legacy theme entries untouched');
  assert.notEqual(ini.readUInt8(0),0xef,'Never UTF-8 BOM-convert the complete game INI');
  const codes=[...correct].filter(c=>c>=128);
  assert.ok(codes.length>4);
  for(const size of [14,16,18]){
    const font=fs.readFileSync(path.join(root,'PhongThanRuntime-Staging/Client/font',size+'.fnt'));
    assert.equal(font.subarray(0,3).toString('ascii'),'ASF');
    assert.equal(font.readUInt32LE(8),256);
    for(const c of codes){
      assert.ok(font.readUInt32LE(16+4*c)>0,'No mapped glyph for byte 0x'+c.toString(16)+' in '+size+'.fnt');
    }
  }
});
