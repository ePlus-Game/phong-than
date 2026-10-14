# Keep the Admin console visible and record failures from early startup.
# PowerShell 5.1 only. Never modifies the game services or account database.
[CmdletBinding()]
param([int]$Port = 8765)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $Root 'PhongThanRuntime-State\logs'
$LogPath = Join-Path $LogDir 'admin-startup.log'
$transcribing = $false
try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Start-Transcript -LiteralPath $LogPath -Append -ErrorAction Stop | Out-Null
    $transcribing = $true
    Write-Host "Admin startup log: $LogPath" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'PhongThan-Admin.ps1') -Port $Port
    throw 'Admin web process returned unexpectedly. Check the startup log.'
} catch {
    Write-Host ''
    Write-Host ('ADMIN STARTUP FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host ('Details: ' + $_.ScriptStackTrace) -ForegroundColor Yellow
    Write-Host "Log: $LogPath" -ForegroundColor Yellow
    # The parent starts this wrapper with powershell.exe -NoExit, so errors
    # remain visible instead of the window disappearing immediately.
} finally {
    if ($transcribing) { Stop-Transcript | Out-Null }
}
