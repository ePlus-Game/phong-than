'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const root=path.join(__dirname,'..');
const html=fs.readFileSync(path.join(root,'AdminWeb/index.html'),'utf8');
const server=fs.readFileSync(path.join(root,'AdminWeb/PhongThan-Admin.ps1'),'utf8');
const sections=[...html.matchAll(/<section\s+id="([^"]+)"/g)].map(x=>x[1]);
const buttons=[...html.matchAll(/<button\s+[^>]*data-t="([^"]+)"/g)].map(x=>x[1]);
const groupMatch=html.match(/const NAV_GROUPS=\[([\s\S]*?)\];/);
const groups=groupMatch?vm.runInNewContext('['+groupMatch[1]+']'):null;

test('all 24 original admin sections and navigation buttons remain',()=>{
  assert.equal(sections.length,24);
  assert.equal(buttons.length,24);
  assert.equal(new Set(sections).size,24);
  assert.deepEqual([...buttons].sort(),[...sections].sort());
});
test('eight logical workspaces cover every existing screen exactly once',()=>{
  assert.ok(groups);
  assert.equal(groups.length,8);
  const ids=groups.flatMap(g=>g.slice(1));
  assert.equal(ids.length,sections.length);
  assert.equal(new Set(ids).size,ids.length);
  assert.deepEqual([...ids].sort(),[...sections].sort());
  assert.ok(groups.some(g=>g[0]==='Trang bị'&&g.includes('gear')&&g.includes('weapons')&&g.includes('upgrade')));
  assert.ok(groups.some(g=>g[0]==='Sự kiện'&&g.includes('events')&&g.includes('evsched')));
});
test('one-of-a-kind static HTML IDs and modern JS parser succeed',()=>{
  const ids=[...html.matchAll(/\bid="([^"]+)"/g)].map(x=>x[1]);
  const duplicated=ids.filter((id,i)=>ids.indexOf(id)!==i);
  assert.deepEqual(duplicated,[]);
  const scripts=[...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)].map(x=>x[1]);
  assert.equal(scripts.length,1);
  assert.doesNotThrow(()=>new vm.Script(scripts[0],{filename:'AdminWeb/index.html inline JavaScript'}));
  assert.ok(html.includes("const TOKEN='__PT_TOKEN__';"));
});
test('contextual navigation, keyboard-friendly mobile menu and deep links',()=>{
  for(const key of ['id="navToggle"','id="navBackdrop"','id="navSearch"','id="workspaceTabs"','class="workspace-eyebrow"']){
    assert.ok(html.includes(key),'Missing '+key);
  }
  assert.match(html,/function ptCloseMenu\(/);
  assert.match(html,/addEventListener\('hashchange'/);
  assert.match(html,/function ptActivatePage\(/);
  assert.match(html,/aria-expanded/);
  assert.match(html,/@media\(max-width:720px\)/);
});
test('overview status cards are populated from existing read-only endpoint',()=>{
  for(const id of ['kpiServices','kpiPlayers','kpiHeartbeat','kpiQueue']){
    assert.ok(html.includes('id="'+id+'"'));
  }
  assert.match(html,/function ptUpdateMetrics\(/);
  assert.match(html,/api\('\/api\/status'\)/);
  assert.match(html,/ptUpdateMetrics\(s,o,alive\)/);
});
test('consolidated token picker delegates to all existing actions without changing routes',()=>{
  const m=html.match(/const ptTokenIds=\[([^\]]+)\]/);
  assert.ok(m);
  const actions=[...m[1].matchAll(/'([^']+)'/g)].map(x=>x[1]);
  assert.equal(actions.length,12);
  assert.equal(new Set(actions).size,12);
  for(const id of actions){
    assert.ok(html.includes('id="'+id+'"'),'Original action absent: '+id);
    assert.ok(html.includes("$('"+id+"').onclick")||html.includes("$('"+id+"').addEventListener"),'Original handler missing: '+id);
  }
  assert.match(html,/original\.click\(\)/);
  assert.match(html,/id='tokenActionSelect'/);
  assert.match(html,/const ptTokenButtons=ptTokenIds/);
  assert.match(html,/type:'give'/);
});
test('PAK catalog safety remains server enforced and disclosed in UI',()=>{
  assert.match(server,/\$script:PakItemCatalogVerified = \[bool\]\$catalog\.PakVerified/);
  assert.match(server,/itemCatalogVerified = \[bool\]\$script:PakItemCatalogVerified/);
  assert.match(server,/'GET \/api\/status'/);
  assert.match(html,/id="catalogNotice"/);
  assert.match(html,/s\.itemCatalogVerified===true/);
  assert.match(html,/phát vật phẩm đang khóa/);
  assert.match(server,/Bang vat pham chua duoc xac minh voi PAK/);
});
test('existing API operations are not renamed or removed by the redesign',()=>{
  const endpoints=['GET /api/status','GET /api/accounts','POST /api/account','POST /api/action','GET /api/characters','GET /api/events','POST /api/events','GET /api/health','GET /api/rollback','GET /api/setup/status','POST /api/setup/run'];
  for(const endpoint of endpoints)assert.ok(server.includes("'"+endpoint+"'"),'Endpoint missing: '+endpoint);
  assert.match(html,/const TOKEN='__PT_TOKEN__'/);
  assert.match(html,/headers:\{'X-PT-Token':TOKEN/);
});
