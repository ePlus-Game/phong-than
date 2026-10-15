'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const html=fs.readFileSync(path.join(__dirname,'../AdminWeb/index.html'),'utf8');
// Execute production functions, with DOM/network boundaries replaced by fixtures.
function source(from,to){const a=html.indexOf(from),b=html.indexOf(to,a+from.length);assert.ok(a>=0&&b>a,from);return html.slice(a,b);}
function load(code,extra={}){const ctx=vm.createContext(extra);vm.runInContext(code,ctx);return ctx;}
function plain(x){return JSON.parse(JSON.stringify(x));}
function apiClient(response){return load(source('async function api(path,body)','function toast('),{TOKEN:'test-token',ptViMessage:s=>'vi:'+s,fetch:response});}
for(const body of [undefined,{type:'money',name:'role_01',value:12}])test('API sends token and '+(body?'POST payload':'GET request'),async()=>{
 let captured;const c=apiClient(async(p,o)=>{captured={p,o};return {ok:true,json:async()=>({ok:true,message:'done',name:'role_01'})};});
 const result=await c.api('/api/action',body);assert.equal(captured.p,'/api/action');assert.equal(captured.o.method,body?'POST':'GET');assert.equal(captured.o.headers['X-PT-Token'],'test-token');assert.equal(captured.o.body,body?JSON.stringify(body):undefined);assert.equal(result.message,'vi:done');assert.equal(result.name,'role_01');
});
for(const [label,response,expected] of [
 ['HTTP failure',{ok:false,status:403,json:async()=>({})},'vi:HTTP 403'],
 ['backend error',{ok:true,json:async()=>({error:'locked'})},'vi:locked'],
 ['malformed JSON',{ok:true,json:async()=>{throw Error('parse');}},'vi:Phản hồi không hợp lệ'],
 ...[null,[],true,3,'unexpected'].map(value=>['invalid envelope '+JSON.stringify(value),{ok:true,json:async()=>value},'Phản hồi không hợp lệ'])
])test('API rejects '+label,async()=>{const c=apiClient(async()=>response);await assert.rejects(c.api('/api/status'),{message:expected});});
test('API propagates network failure',async()=>{const c=apiClient(async()=>{throw Error('offline');});await assert.rejects(c.api('/api/status'),{message:'offline'});});
test('escaping protects markup and preserves Vietnamese and zero values',()=>{const c=load(source('const esc=','let pickedItem=')+'this.escape=esc;');assert.equal(c.escape('<img x="&">'), '&lt;img x=&quot;&amp;&quot;&gt;');assert.equal(c.escape('Đạo Sĩ'),'Đạo Sĩ');assert.equal(c.escape(0),'0');assert.equal(c.escape(null),'');});
test('bot settings clamp limits without modifying input spots',()=>{const nodes={botFollow:{checked:true},botFollowCount:{value:'1000'},botParty:{checked:false},botPartyCount:{value:'-2'},botPartyBonus:{value:'99'}};const spots=[{map:1,x:-2,y:5,count:999,level:999}];const before=JSON.stringify(spots);const c=load(source('function botBody(enabled)','$(\'btnBotApply\')'),{$:id=>nodes[id],botSpots:spots});const b=plain(c.botBody(false));assert.deepEqual(b,{type:'bots',enabled:false,follow:true,followCount:100,party:false,partyCount:0,partyBonus:50,spots:[{map:1,x:0,y:5,count:100,level:200}]});assert.equal(JSON.stringify(spots),before);});
test('density reset restores defaults and preserves map selection',()=>{const c=load(source('function mdBody(off)','$(\'btnMdApply\')'),{document:{querySelector:()=>({value:'selected'})},$:()=>({value:'25'}),mdRevive:()=>10,mdPick:new Set([1,2])});assert.deepEqual(plain(c.mdBody(false)),{type:'matdo',density:25,revive:10,all:false,maps:[1,2]});assert.deepEqual(plain(c.mdBody(true)),{type:'matdo',density:10,revive:0,all:true,maps:[1,2]});});
test('event serialization keeps IDs, numeric fields and selected weekdays',()=>{const fields=[{dataset:{f:'map'},tagName:'SELECT',value:'12'},{dataset:{f:'count'},type:'number',value:'3'},{dataset:{f:'text'},value:'Thông báo'}];const row={dataset:{type:'spawn'},querySelectorAll:()=>fields};const nodes={evActions:{children:[row]},evId:{value:'e123'},evName:{value:'  Test  '},evTime:{value:'20:30'},evEnabled:{checked:true},evDays:{querySelectorAll:()=>[{value:'0'},{value:'6'}]}};const c=load(source('function collectEvent()','function resetEvent()'),{$:id=>nodes[id]});assert.deepEqual(plain(c.collectEvent()),{id:'e123',name:'Test',time:'20:30',enabled:true,days:[0,6],actions:[{type:'spawn',mode:'map',map:12,count:3,text:'Thông báo'}]});});
test('party distribution respects weights, disabled classes and does not mutate them',()=>{const c=load(source('function bpClasses(','function bpW('));const w=[2,1,0],before=[...w];const result=plain(c.bpClasses(30,w));assert.equal(result.length,30);assert.equal(result.filter(x=>x===0).length,20);assert.equal(result.filter(x=>x===1).length,10);assert.ok(!result.includes(2));assert.deepEqual(w,before);assert.deepEqual(plain(c.bpClasses(5,[0,0,0])),[]);});
test('dashboard metrics distinguish missing heartbeat and pending commands',()=>{const nodes={};for(const id of ['kpiServices','kpiPlayers','kpiHeartbeat','kpiQueue'])nodes[id]={};const c=load(source('function ptUpdateMetrics(','function debounce('),{$:id=>nodes[id]});c.ptUpdateMetrics({services:['GameServer.exe','Bishop.exe'],heartbeatAgeSec:-1,pendingQueued:true},{players:[{},{}]},false);assert.equal(nodes.kpiServices.textContent,'2/5');assert.equal(nodes.kpiPlayers.textContent,'2');assert.equal(nodes.kpiHeartbeat.textContent,'Chưa có');assert.equal(nodes.kpiQueue.textContent,'Có lệnh chờ');c.ptUpdateMetrics({heartbeatAgeSec:160},{},false);assert.equal(nodes.kpiHeartbeat.textContent,'Trễ 160s');c.ptUpdateMetrics({}, {},true);assert.equal(nodes.kpiHeartbeat.textContent,'Hoạt động');});
