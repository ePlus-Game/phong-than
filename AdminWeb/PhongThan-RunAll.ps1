param([switch]$WithClient)
# One-click start: database -> native server -> admin web (optional client).
# In server/admin-only mode, do not alter the client binaries or PAK.
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Project = Join-Path $Root 'PhongThanSource'
$Runtime = Join-Path $Root 'PhongThanRuntime-Staging'
$ServerDir = Join-Path $Runtime 'Server'
$ClientExe = Join-Path $Runtime 'Client\Game.exe'
$AdminPort = 8765
$RequiredServerNames = @('Goddess.exe', 'PhongThanAccountServer.exe', 'PhongThanRelay.exe', 'Bishop.exe', 'GameServer.exe')

function Step([string]$m) { Write-Host ''; Write-Host "== $m" -ForegroundColor Cyan }
function Get-ServerProcs {
    @(Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($ServerDir + '\', [StringComparison]::OrdinalIgnoreCase) })
}
function Test-Port([int]$p) {
    $c = New-Object Net.Sockets.TcpClient
    try { $c.Connect('127.0.0.1', $p); return $true }
    catch { return $false }
    finally { $c.Dispose() }
}

try {
    # Fail before database/server side effects if --WithClient has no executable.
    if ($WithClient -and -not (Test-Path -LiteralPath $ClientExe -PathType Leaf)) {
        throw "Khong tim thay client: $ClientExe"
    }

    # Reject a partially running native server before *any* DB or client changes.
    $running = @(Get-ServerProcs)
    if ($running.Count -gt 0) {
        $found = @($running | ForEach-Object { $_.Name.ToLowerInvariant() } | Sort-Object -Unique)
        $missing = @($RequiredServerNames | Where-Object { $found -notcontains $_.ToLowerInvariant() })
        if ($missing.Count -gt 0) {
            throw "Server dang chay mot phan (thieu: $($missing -join ', ')). Khong setup DB hoac client cho den khi duoc xu ly."
        }
    }

    # Restore missing split PAKs before native runtime validation; never mutate
    # assets while any game services are already running.
    if ($running.Count -eq 0) {
        Step '0/3 Khoi phuc PAK (Windows PowerShell, khong can Python)'
        & (Join-Path $Root 'tools\Restore-SplitPaks.ps1') -RepoRoot $Root
    }

    Step '1/3 Kiem tra SQL LocalDB va database account'
    if ($running.Count -eq 0) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'PhongThan-Setup.ps1') -Step all
        if ($LASTEXITCODE -ne 0) { throw 'Cai dat database that bai (xem dong LOI o tren).' }
    } else {
        Write-Host 'Da co du 5 service. Bo qua setup/restore DB de bao toan phien dang chay.'
    }

    if ($WithClient) {
        Step 'Kiem tra va client truoc khi mo game'
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'PhongThan-ClientPatch.ps1')
        if ($LASTEXITCODE -ne 0) { throw 'Client patch that bai. Khong mo game.' }
    }

    Step '2/3 Khoi dong server'
    $running = @(Get-ServerProcs)
    if ($running.Count -gt 0) {
        $found = @($running | ForEach-Object { $_.Name.ToLowerInvariant() } | Sort-Object -Unique)
        $missing = @($RequiredServerNames | Where-Object { $found -notcontains $_.ToLowerInvariant() })
        if ($missing.Count -gt 0) {
            throw "Server dang chay mot phan (thieu: $($missing -join ', ')). Kiem tra log va khoi phuc thu cong; khong tu dong khoi dong chong cheo."
        }
        Write-Host 'Da tim thay 5 tien trinh server; bo qua khoi dong trung. Tinh trang WORLD_READY van can kiem tra trong log.'
    } else {
        $startup = @(& (Join-Path $Project 'Deploy\Start-NativeServer.ps1') -ProjectRoot $Project -RuntimeRoot $Runtime)
        if (@($startup | Where-Object { $_.Status -eq 'READY_FOR_LOGIN' }).Count -eq 0) {
            throw 'Script khoi dong khong tra ve READY_FOR_LOGIN; can kiem tra server.'
        }
        Write-Host 'Server da khoi dong va xac nhan WORLD_READY.'
    }

    Step '3/3 Mo web admin'
    if (Test-Port $AdminPort) {
        Write-Host "Co dich vu tai http://localhost:$AdminPort/ (can xac minh day la web admin)"
        Start-Process "http://localhost:$AdminPort/"
    } else {
        Start-Process -FilePath 'powershell.exe' -WorkingDirectory $PSScriptRoot -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$(Join-Path $PSScriptRoot 'PhongThan-Admin.ps1')`"")
        Write-Host "Dang mo web admin (cua so rieng): http://localhost:$AdminPort/"
    }

    if ($WithClient) {
        Step 'Mo client game'
        $env:__COMPAT_LAYER = 'HIGHDPIAWARE'
        Start-Process -FilePath $ClientExe -WorkingDirectory (Join-Path $Runtime 'Client')
    }
    Write-Host ''
    Write-Host 'HOAN TAT: da thuc hien cac buoc launcher. Vui long kiem tra server/client thuc te.' -ForegroundColor Green
    exit 0
} catch {
    Write-Host ('LOI: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
