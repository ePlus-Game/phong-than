function reset()
    level=200 cash=10000 morph=0 inside=0 pk=0 camp=1 result=1
    paid=0 moved=0 closed=0 fightChanges=0 revChanges=0 menus=0
end
function GetLevel() return level end
function GetCash() return cash end
function GetMorphType() return morph end
function IsPlayerInsideWeapon(p) return inside end
function GetPK() return pk end
function GetCamp() return camp end
function NewWorld(w,x,y) moved=moved+1 target=w return result end
function Pay(n) paid=paid+n end
function SetFightState(n) fightChanges=fightChanges+1 end
function SetRevPos(w,p) revChanges=revChanges+1 end
function CloseDialog() closed=closed+1 end
function Msg2Player(s) end
function Talk(a,b,c) end
function Say(a,b,c) menus=menus+1 end

reset() main() assert(menus==1)
reset() morph=364 main() assert(menus==0)
reset() inside=1 PTExit_Go(2,1608,3196,1) assert(moved==0 and paid==0)
reset() cash=4999 ccdy() assert(moved==0 and paid==0)
local destinations={ccdy,yxg,cym,cg,xq,fst,yc,v58}
local maps={2,3,4,21,20,1,52,57}
local i=1
while destinations[i] do
    reset() result=0 destinations[i]()
    assert(moved==1 and paid==0 and fightChanges==0 and closed==1)
    reset() destinations[i]()
    assert(moved==1 and target==maps[i] and paid==5000 and closed==1)
    i=i+1
end
reset() result=2 ccdy() assert(paid==0) -- server handoff is not confirmed arrival
reset() result=0 ygzc() assert(paid==0 and revChanges==0 and fightChanges==0)
reset() ygzc() assert(target==64 and paid==5000 and revChanges==1 and fightChanges==1)
reset() pk=88 ygzc() assert(moved==0 and paid==0)
reset() camp=0 ygzc() assert(moved==0 and paid==0)
reset() v100() assert(moved==0 and paid==0)
reset() level=29 v100() assert(target==66 and paid==200 and fightChanges==1)
reset() level=29 result=0 v100() assert(paid==0 and fightChanges==0)
print('PASS: actual town portal Lua, destination callbacks, level/cash/state guards, failed and pending transfer never charged')
