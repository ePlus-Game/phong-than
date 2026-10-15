# Functional tests of production admin functions with disposable data and mocked OS/SQL boundaries.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
$tokens=$null;$parseErrors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $RepoRoot 'AdminWeb\PhongThan-Admin.ps1'),[ref]$tokens,[ref]$parseErrors)
if ($parseErrors.Count) { throw 'Backend parse errors' }
$names=@('ConvertFrom-Tcvn','ConvertTo-Tcvn','ConvertTo-LuaString','Get-Plain','Get-ItemCode','Assert-Name','Clamp','Invoke-Action','Get-Online','Set-Bots','Get-BotsConfig','Set-MatDo','Get-MatDoConfig','Set-BotParty','Get-BotPartyConfig','ConvertTo-BotPartyKey','Set-EventSched','Get-EvConfig','New-DgRow','ConvertTo-DgRow','Set-DailyGift','Get-DgConfig','Get-ClientCfg','Set-ClientCfg','Get-ClientSound','Set-ClientSound','Get-ChestPath','Get-ChestFnv','Read-ChestFile','Set-ChestFile','Invoke-AccountAction','Get-Md5Upper','Get-AdminOpsFnv','Test-AdminOpsPthc','Read-AdminOpsRole','Get-AdminOpsCharName','Get-AdminOpsCharFile','Get-AdminOpsTrashEntry','Get-CharDeletePlan','Invoke-CharDelete','Get-CharUndeletePlan','Invoke-CharUndelete','Assert-AdminOpsCharOffline','New-AdminOpsCode','Confirm-AdminOpsCode','Write-AdminOpsLog','Get-CharRestoreFiles','Get-CharRestorePlan','Invoke-CharRestore','Assert-AdminOpsStopped','Invoke-CharBackup','Get-CharBackups','Read-JsonList','Save-Json','Update-Results')
foreach($name in $names) {
 $found=@($ast.FindAll({param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name},$true))
 if($found.Count -ne 1){throw "Missing production function $name"}
 . ([scriptblock]::Create($found[0].Extent.Text))
}
# Import only literal catalog assignments, never the startup/server statements.
foreach($name in @('tcvnFrom','tcvnTo','BiKipMats','BiKipTier','BiKipByProf','ThanKy','ThanKyStones','ProfRanges')) {
 $found=@($ast.FindAll({param($node) $node -is [Management.Automation.Language.AssignmentStatementAst] -and $node.Left -is [Management.Automation.Language.VariableExpressionAst] -and $node.Left.VariablePath.UserPath -eq $name},$true))
 if($found.Count -ne 1){throw "Expected catalog assignment $name"}
 . ([scriptblock]::Create($found[0].Extent.Text))
}
$TcvnToUni=@{};$UniToTcvn=@{}
for($i=0;$i -lt $tcvnFrom.Count;$i++){ $TcvnToUni[[int]$tcvnFrom[$i]]=[char]$tcvnTo[$i];$UniToTcvn[[char]$tcvnTo[$i]]=[byte]$tcvnFrom[$i] }
$Enc1252=[Text.Encoding]::GetEncoding(1252);$Utf8=New-Object Text.UTF8Encoding($false)
$Root=Join-Path ([IO.Path]::GetTempPath()) ('pt-admin-test-'+[guid]::NewGuid().ToString('N'))
$Runtime=Join-Path $Root 'runtime';$ServerRoot=Join-Path $Runtime 'Server';$Bridge=Join-Path $ServerRoot 'admin_bridge';$DataDir=Join-Path $Root 'data'
$CharStoreDir=Join-Path $ServerRoot 'CharacterStore';$CharBackupRoot=Join-Path $Root '_backup\characters';$CharTrashRoot=Join-Path $CharBackupRoot 'deleted';$CharAccountLimit=3;$CharBackupKeep=7
$AdminOpsLogPath=Join-Path $DataDir 'adminops.log';$script:AdminOpsCodes=@{}
$ClientCfgPath=Join-Path $Runtime 'Client\config.ini';$ClientUiCommonPath=Join-Path $Runtime 'Client\UserData\UiCommon.ini'
$BotsJsonPath=Join-Path $DataDir 'bots.json';$MatDoJsonPath=Join-Path $DataDir 'matdo.json';$BotPartyJsonPath=Join-Path $DataDir 'botparty.json';$EvJsonPath=Join-Path $DataDir 'eventsched.json';$DgJsonPath=Join-Path $DataDir 'dailygift.json'
$HistoryPath=Join-Path $DataDir 'history.json';$script:History=New-Object Collections.ArrayList;$script:ResultOffset=0L
$Maps=@([pscustomobject]@{id=1001;name='Map A'},[pscustomobject]@{id=1002;name='Map B'});$mapNames=@{1001='Map A';1002='Map B'};$MatDoMaps=@(1001,1002)
$Npcs=@([pscustomobject]@{id=0;name='NPC A'},[pscustomobject]@{id=1;name='NPC B'})
$WorldBoss=@([pscustomobject]@{key='test_boss';name='Boss'});$EvKinds=@('vantien','thuongchu','boss','exp')
$RebirthByProf=@{0=@(1481,1482,1483);1=@(1484,1485,1486);2=@(1487,1488,1489,450)}
$ItemByKey=@{'MagicScript|1'=[pscustomobject]@{group='MagicScript';code=1;name='Fixture item'}};$script:PakItemCatalogVerified=$true
$script:commands=New-Object Collections.ArrayList;$script:covered=@{};$script:failures=New-Object Collections.ArrayList;$script:passed=0;$script:gameRunning=$false
function Get-Process { param($Name,$ErrorAction) if($script:gameRunning){[pscustomobject]@{ProcessName='Game'}} }
function Get-AdminOpsRunning { param($Names) if($script:gameRunning){'GameServer'} }
function Test-AdminOpsLocalDb { $false }
function Invoke-AdminOpsDbBackup { throw 'TEST: SQL backup must never execute' }
function Get-UpgradeLua { '-- fixture upgrade library' }
function Add-BridgeCommand([string]$Type,[string]$Description,[string]$LuaTemplate) {
 $entry=[pscustomobject]@{id=('fixture'+$script:commands.Count);type=$Type;desc=$Description;lua=$LuaTemplate}
 [void]$script:commands.Add($entry);$entry
}
function Assert($ok,[string]$message){if(-not $ok){throw $message}}
function Reject([scriptblock]$body){$caught=$false;try{& $body | Out-Null}catch{$caught=$true};Assert $caught 'Expected rejection'}
function Case([string]$label,[scriptblock]$body){try{& $body | Out-Null;$script:passed++;Write-Host "PASS: $label"}catch{[void]$script:failures.Add("${label}: $($_.Exception.Message)");Write-Host "FAIL: ${label}: $($_.Exception.Message)"}}
function Action($data,[string]$expected){
 $script:covered[$data.type]=$true;$before=$script:commands.Count;Invoke-Action ([pscustomobject]$data) | Out-Null
 Assert ($script:commands.Count -eq $before+1) 'Expected exactly one queued command'
 Assert ($script:commands[$before].lua -match $expected) "Wrong command for $($data.type): $($script:commands[$before].lua)"
}
function BadAction($data){$n=$script:commands.Count;Reject {Invoke-Action ([pscustomobject]$data)};Assert ($script:commands.Count -eq $n) 'Rejected input queued a command'}
function Write-Role([string]$name,[string]$account='account1') {
 $bytes=New-Object byte[] 424
 [Array]::Copy([BitConverter]::GetBytes([uint32]0x43544850),0,$bytes,0,4)
 [Array]::Copy([BitConverter]::GetBytes([uint16]1),0,$bytes,4,2)
 [Array]::Copy([BitConverter]::GetBytes([uint16]16),0,$bytes,6,2)
 [Array]::Copy([BitConverter]::GetBytes([uint32]408),0,$bytes,8,4)
 $nb=ConvertTo-Tcvn $name;[Array]::Copy($nb,0,$bytes,32,$nb.Length)
 $ab=$Enc1252.GetBytes($account);[Array]::Copy($ab,0,$bytes,64,$ab.Length)
 [Array]::Copy([BitConverter]::GetBytes([int]20),0,$bytes,224,4)
 [Array]::Copy([BitConverter]::GetBytes([uint32](Get-AdminOpsFnv $bytes)),0,$bytes,12,4)
 $file=Get-ChestPath $name;[IO.File]::WriteAllBytes($file,$bytes);$file
}
try {
 New-Item -ItemType Directory -Force $Root,$Bridge,$DataDir,$CharStoreDir,$CharBackupRoot,(Split-Path -Parent $ClientCfgPath),(Split-Path -Parent $ClientUiCommonPath) | Out-Null
 Case 'give / gear / mount item dispatch and count cap' {Action @{type='give';player='Hero';itemKey='MagicScript|1';count=999} 'PTAdm_Give\(\{ID\}, "Hero", 6, 1, 0, 1, 0, 50,'}
 Case 'giveall dispatch' {Action @{type='giveall';itemKey='MagicScript|1';count=2} 'PTAdm_GiveAll.*2,'}
 Case 'unknown item blocked' {BadAction @{type='give';player='Hero';itemKey='missing';count=1}}
 Case 'unverified PAK blocks item dispatch' {$script:PakItemCatalogVerified=$false;try{BadAction @{type='give';player='Hero';itemKey='StarterBag';count=1}}finally{$script:PakItemCatalogVerified=$true}}
 Case 'money limit' {Action @{type='money';player='Hero';amount=-1} 'PTAdm_Money.* 1\)'}
 Case 'coin account currency' {Action @{type='coin';player='Hero';amount=9999999} 'AddExtPoint\(1000000\)'}
 Case 'experience limit' {Action @{type='exp';player='Hero';amount=5} 'PTAdm_Exp.* 5\)'}
 Case 'skills filter wrong profession and duplicates' {Action @{type='skills';player='Hero';prof=0;skills=@(27,27,3,1481);level=20} 'PTAdm_SetSkills.*0, 10, \{27, 1481\}'}
 Case 'skills reject unsupported profession' {BadAction @{type='skills';player='Hero';prof=9;skills=@(27)}}
 Case 'skills reject empty valid selection' {BadAction @{type='skills';player='Hero';prof=0;skills=@(3)}}
 Case 'level preserves skill groups in emitted command' {Action @{type='level';player='Hero';level=999} 'SetLevel\(200\).*SetSkillLevel'}
 Case 'attribute add' {Action @{type='attr';player='Hero';str=5;prop=2} 'AddProp\(5\).*AddStrg\(5\).*AddProp\(2\)'}
 Case 'attribute info' {Action @{type='attr';player='Hero';info=$true} 'GetStrg\(1\)'}
 Case 'attribute reset' {Action @{type='attr';player='Hero';reset=$true} 'ResetProp\(\)'}
 Case 'attribute rejects zero allocation' {BadAction @{type='attr';player='Hero'}}
 Case 'upgrade list' {Action @{type='upgradelist';player='Hero'} 'PTUP_List'}
 Case 'upgrade item and level' {Action @{type='upgradeset';player='Hero';itemId='123';level=99} 'PTUP_Set.*123, 12,'}
 Case 'upgrade rejects missing item' {BadAction @{type='upgradeset';player='Hero';itemId=0;level=2}}
 Case 'upgrade rejects fractional ID instead of rounding' {BadAction @{type='upgradeset';player='Hero';itemId='1.5';level=2}}
 Case 'news trims and escapes Lua' {Action @{type='news';text=' Hello "world" '} 'PTAdm_News.*Hello \\034world\\034'}
 Case 'news rejects blank or too long' {BadAction @{type='news';text=' '};BadAction @{type='news';text=('a'*251)}}
 Case 'spawn near player' {Action @{type='spawn';mode='player';player='Hero';npc=1;level=50;count=2} 'PTAdm_SpawnNear.*1, 50, "Hero", 2'}
 Case 'spawn on map' {Action @{type='spawn';mode='map';map=1001;npc=1;level=50;x=1;y=2;count=2} 'PTAdm_SpawnAt.*1, 50, 1001, 1, 2, 2'}
 Case 'spawn rejects map outside server catalog' {BadAction @{type='spawn';mode='map';map=9999;npc=1;level=50;count=1}}
 Case 'spawn resolves sparse catalog IDs' { $saved=$Npcs;try{$Npcs=@([pscustomobject]@{id=4;name='sparse'});Action @{type='spawn';mode='map';map=1001;npc=4;level=50;x=1;y=2;count=1} 'PTAdm_SpawnAt.*4, 50'}finally{$Npcs=$saved} }
 Case 'spawn rejects absent NPC instead of substituting another' {BadAction @{type='spawn';mode='player';player='Hero';npc=999;level=50;count=1}}
 Case 'clear spawned NPCs only' {Action @{type='clear'} 'PTAdm_ClearSpawned'}
 Case 'world boss dispatch' {Action @{type='wbspawn';key='test_boss'} 'PTWB_SpawnKey\("test_boss"\)'}
 Case 'world boss rejects unknown key' {BadAction @{type='wbspawn';key='missing'}}
 Case 'Van Tien open' {Action @{type='vtopen';tran=4} 'PTVT_AdminOpen\(4\)'}
 Case 'Van Tien rejects invalid instance' {BadAction @{type='vtopen';tran=5}}
 Case 'book materials by tier' {Action @{type='bikipmats';player='Hero';bundle=1;tiers=@(139)} 'PTAdm_GiveTo'}
 Case 'book materials reject empty' {BadAction @{type='bikipmats';player='Hero';mats=@{}}}
 Case 'profession books' {Action @{type='bikip';player='Hero';prof=0;skills=@(27);count=1} 'PTAdm_GiveTo.*62027'}
 Case 'profession books reject wrong class' {BadAction @{type='bikip';player='Hero';prof=0;skills=@(3)}}
 foreach($mode in @('info','stone','teach','manh','book')) {
  $modeValue=$mode
  Case "Than Ky $mode" {Action @{type='thanky';mode=$modeValue;player='Hero';skills=@(1986);stones=@(6854);count=1;cap=1;level=2} 'PTAdm_FindPlayer'}
 }
 Case 'Than Ky rejects empty selection' {BadAction @{type='thanky';mode='teach';player='Hero';skills=@()}}
 Case 'chest information' {Action @{type='chest';player='Missing';info=$true} 'GetExpandBox'}
 Case 'chest online queues without touching character file' {
  $file=Write-Role 'Hero';$before=[Convert]::ToBase64String([IO.File]::ReadAllBytes($file))
  [IO.File]::WriteAllText((Join-Path $Bridge 'online.txt'),"stamp`nHero`taccount1`t20`t1001`t1`t2`t0`n",$Enc1252)
  Action @{type='chest';player='Hero';to=6} 'SetExpandBox\(5\)'
  Assert ([Convert]::ToBase64String([IO.File]::ReadAllBytes($file)) -eq $before) 'ONLINE CHARACTER FILE WAS MODIFIED'
  Remove-Item -LiteralPath (Join-Path $Bridge 'online.txt')
 }
 Case 'auto-fight token skills and bitmask' {Action @{type='lbskills';player='Hero';which=1;skills=@(3,4,4)} 'PTLB_AdminSet.*1, 3\)'}
 Case 'auto-fight token disabled' {Action @{type='lbskills';player='Hero';which=2;off=$true} 'PTLB_AdminSet.*2, 0\)'}
 Case 'auto-fight rejects wrong token kind' {BadAction @{type='lbskills';player='Hero';which=4}}
 Case 'max class skill' {Action @{type='lbmax';player='Hero';prof=0;skill=27} 'PTLB_AdminMax.*0, 27\)'}
 Case 'max skill rejects different class' {BadAction @{type='lbmax';player='Hero';prof=0;skill=3}}
 Case 'bag filters deduplicate bits' {Action @{type='hanhtrang';player='Hero';pick=@(0,1,1,999);sell=@(0,2);blv=999} 'PTHT_AdminSet.*3, 5, 11\)'}
 Case 'bag default filters' {Action @{type='hanhtrang';player='Hero';default=$true} 'PTHT_AdminSet.*1789, 3, 5\)'}
 Case 'pet food dispatch' {Action @{type='nuoithugive';player='Hero';itemKey='NuoiThuLTDon';count=9999} 'PTAdm_Give.*1000,'}
 Case 'pet food rejects arbitrary item' {BadAction @{type='nuoithugive';player='Hero';itemKey='StarterBag';count=1}}
 Case 'pet feeding' {Action @{type='nuoithu';player='Hero';mode=1} 'PTNT_AdminFeed.*1\)'}
 Case 'pet max level' {Action @{type='nuoithu';player='Hero';mode=2} 'PTNT_AdminFeed.*2\)'}
 Case 'pet rejects invalid mode' {BadAction @{type='nuoithu';player='Hero';mode=3}}
 Case 'run saved event' {Action @{type='evrun';id=4} 'PTEV_AdminRun.*4\)'}
 Case 'stop double experience' {Action @{type='evstopexp'} 'PTEV_AdminStopExp'}
 Case 'unsupported action rejected' {BadAction @{type='unsupported'}}
 Case 'missing character rejected' {BadAction @{type='money';player='';amount=1}}
 Case 'bots save readback and replacement' {
  Action @{type='bots';enabled=$true;follow=$true;followCount=5;spots=@([pscustomobject]@{map=1001;x=2;y=3;count=4;level=20})} 'PTBOT_AdminApply'
  $cfg=Get-BotsConfig;Assert ($cfg.spots.Count -eq 1 -and $cfg.followCount -eq 5) 'bot readback failed'
  Action @{type='bots';enabled=$false;followCount=5;spots=@()} 'PTBOT_AdminApply'
  Assert (-not (Get-BotsConfig).enabled) 'bot disable not persisted'
 }
 Case 'bots reject invalid map' {BadAction @{type='bots';enabled=$true;spots=@([pscustomobject]@{map=9999})}}
 Case 'density save readback and deduplicate' {
  Action @{type='matdo';density=20;revive=1;all=$false;maps=@(1001,1001)} 'PTEXT_matdo_Apply'
  $cfg=Get-MatDoConfig;Assert ($cfg.maps.Count -eq 1 -and $cfg.revive -eq 3) 'density bounds failed'
 }
 Case 'density rejects invalid multiplier' {BadAction @{type='matdo';density=99;all=$true}}
 Case 'density rejects empty selected maps' {BadAction @{type='matdo';density=20;all=$false;maps=@()}}
 Case 'bot party save and readback' {Set-BotParty ([pscustomobject]@{count=3;gs=1;ds=1;dn=1;lvoff=2;chars=@([pscustomobject]@{name='Hero';mode=1;count=2})});$cfg=Get-BotPartyConfig;Assert ($cfg.count -eq 3 -and $cfg.chars[0].name -eq 'Hero') 'party readback failed'}
 Case 'bot party duplicate character rejected' {Reject {Set-BotParty ([pscustomobject]@{chars=@([pscustomobject]@{name='Hero';mode=1},[pscustomobject]@{name='hero';mode=1})})}}
 Case 'game schedule save and readback' {Set-EventSched ([pscustomobject]@{enabled=$true;pre=5;rows=@([pscustomobject]@{id=1;on=$true;days='0123456';hh=20;mm=30;kind='boss';key='test_boss'})});Assert ((Get-EvConfig).rows[0].key -eq 'test_boss') 'schedule not persisted'}
 Case 'game schedule rejects duplicate row IDs' {Reject {Set-EventSched ([pscustomobject]@{rows=@([pscustomobject]@{id=1;days='0';kind='exp'},[pscustomobject]@{id=1;days='1';kind='exp'})})}}
 Case 'daily gift save and readback' {Set-DailyGift ([pscustomobject]@{enabled=$true;moneyDaily=10;moneyBig=20;daily=@([pscustomobject]@{key='MagicScript|1';n=2});big=@()});$cfg=Get-DgConfig;Assert ($cfg.daily[0].g -eq 6 -and $cfg.daily[0].d -eq 1 -and $cfg.daily[0].p -eq 1) 'daily gift VNG tuple incorrect'}
 Case 'daily gift rejects equipment row' {Reject {Set-DailyGift ([pscustomobject]@{daily=@([pscustomobject]@{g=0;name='invalid'})})}}
 Case 'client config updates only Client section' {
  [IO.File]::WriteAllText($ClientCfgPath,"[Client]`r`nScreenWidth=800`r`nScreenHeight=600`r`nFullScreen=0`r`n[Other]`r`nScreenWidth=77`r`n",$Enc1252)
  Set-ClientCfg ([pscustomobject]@{width=1024;height=768;fullScreen=1})
  $cfg=Get-ClientCfg;Assert ($cfg.width -eq 1024 -and $cfg.height -eq 768) 'readback picked unrelated INI section'
  Assert ([IO.File]::ReadAllText($ClientCfgPath).Contains('ScreenWidth=77')) 'unrelated setting was modified'
 }
 Case 'client config creates missing Client section' {
  [IO.File]::WriteAllText($ClientCfgPath,"[Other]`r`nKey=keep`r`n",$Enc1252)
  Set-ClientCfg ([pscustomobject]@{width=800;height=600;fullScreen=0})
  Assert ([IO.File]::ReadAllText($ClientCfgPath).Contains('[Client]')) 'missing Client section not created'
 }
 Case 'client config rejects unsupported resolution' {Reject {Set-ClientCfg ([pscustomobject]@{width=1920;height=1080})}}
 Case 'sound save and readback' {Set-ClientSound ([pscustomobject]@{music=25;sound=40});$cfg=Get-ClientSound;Assert ($cfg.music -eq 25 -and $cfg.sound -eq 40) 'sound readback failed'}
 Case 'sound refuses running game' {$script:gameRunning=$true;try{Reject {Set-ClientSound ([pscustomobject]@{music=5;sound=5})}}finally{$script:gameRunning=$false}}
 Case 'sound rejects invalid volume' {Reject {Set-ClientSound ([pscustomobject]@{music=101;sound=40})}}
 Case 'offline chest update creates backup and checksum' {
  Remove-Item -LiteralPath (Join-Path $Bridge 'online.txt') -ErrorAction SilentlyContinue
  $file=Write-Role 'Hero';$r=Set-ChestFile 'Hero' 3;Assert $r.ok 'offline chest write failed'
  Assert ((Read-ChestFile 'Hero').box -eq 3) 'wrong chest count';Assert (Test-AdminOpsPthc ([IO.File]::ReadAllBytes($file))) 'invalid checksum'
  Set-ChestFile 'Hero' 1;Assert ((Read-ChestFile 'Hero').box -eq 3) 'chest was downgraded'
 }
 Case 'character delete refuses online and stale state' {
  [IO.File]::WriteAllText((Join-Path $Bridge 'online.txt'),"stamp`nHero`taccount1`t20`t1001`t1`t2`n",$Enc1252)
  function Get-AdminOpsOnlineState {[pscustomobject]@{names=@('hero');ageSec=0;server=$true}}
  Reject {Assert-AdminOpsCharOffline 'Hero'}
  function Get-AdminOpsOnlineState {[pscustomobject]@{names=@();ageSec=999;server=$true}}
  Reject {Assert-AdminOpsCharOffline 'Hero'}
 }
 Case 'character soft delete and restore fixture round trip' {
  function Get-AdminOpsOnlineState {[pscustomobject]@{names=@();ageSec=0;server=$false}}
  Remove-Item -LiteralPath (Join-Path $Bridge 'online.txt') -ErrorAction SilentlyContinue
  $file=Write-Role 'RestoreMe' 'account2';$hash=(Get-FileHash -LiteralPath $file).Hash;$leaf=Split-Path -Leaf $file
  $plan=Get-CharDeletePlan $leaf;Invoke-CharDelete $leaf $plan.code 'RestoreMe'
  Assert (-not (Test-Path -LiteralPath $file)) 'deleted character still active'
  $folder=(Get-ChildItem -LiteralPath $CharTrashRoot -Directory | Where-Object Name -like '*RestoreMe' | Select-Object -First 1).Name
  $plan=Get-CharUndeletePlan $folder;Invoke-CharUndelete $folder $plan.code
  Assert ((Get-FileHash -LiteralPath $file).Hash -eq $hash) 'restored bytes differ'
 }
 Case 'character backup and restore fixture round trip' {
  $file=Write-Role 'BackupMe' 'account3';$hash=(Get-FileHash -LiteralPath $file).Hash;Invoke-CharBackup 'unit test'
  $date=Get-Date -Format 'yyyyMMdd';$leaf=Split-Path -Leaf $file
  [IO.File]::WriteAllText($file,'damaged',$Enc1252)
  $plan=Get-CharRestorePlan $date $leaf;Invoke-CharRestore $date $leaf $plan.code
  Assert ((Get-FileHash -LiteralPath $file).Hash -eq $hash) 'backup restore bytes differ'
 }
 Case 'backup path traversal rejected' {Reject {Get-CharRestoreFiles '..\outside' '*'};Reject {Get-AdminOpsCharFile '..\outside.pthc'};Reject {Get-AdminOpsTrashEntry '..\outside'}}
 Case 'history applies bridge result' {
  $entry=[pscustomobject]@{id='unit1';status='PENDING';detail=''};[void]$script:History.Add($entry)
  [IO.File]::WriteAllText((Join-Path $Bridge 'result.log'),"stamp`tunit1`tOK`tdone`r`n",$Enc1252);Update-Results
  Assert ($entry.status -eq 'OK' -and $entry.detail -match 'done') 'bridge result not applied'
 }
 Case 'all action types exercised' {
  $actionNode=@($ast.FindAll({param($node)$node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-Action'},$true))[0]
  $types=@([regex]::Matches($actionNode.Extent.Text,"(?m)^        '([^']+)' \{") | ForEach-Object {$_.Groups[1].Value})
  Assert ($types.Count -gt 20) 'action discovery failed'
  foreach($type in $types){Assert ($script:covered.ContainsKey($type)) "No scenario for $type"}
 }
} finally {
 # Root is created only by this test under OS temp; never accepts a runtime path.
 if(Test-Path -LiteralPath $Root){Remove-Item -LiteralPath $Root -Recurse -Force}
}
Write-Host "FEATURE RESULTS: $script:passed passed; $($script:failures.Count) failed"
if($script:failures.Count){throw ($script:failures -join "`n")}
