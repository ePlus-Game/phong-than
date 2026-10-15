# Install the official GitHub Actions PAK reader without modifying any game DLL/PAK/SQL.
# PowerShell 5.1. Either supply -ZipPath from the Actions artifact, or use gh CLI
# authenticated to GitHub to download the latest successful main workflow build.
[CmdletBinding()]
param(
    [string]$ZipPath,
    [long]$RunId = 0,
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)
$ErrorActionPreference = 'Stop'
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot)
$AdminRoot = Join-Path $RepoRoot 'AdminWeb'
$ServerRoot = Join-Path $RepoRoot 'PhongThanRuntime-Staging\Server'
$InstallerSource = Join-Path $AdminRoot 'Initialize-ItemTables.ps1'
$Target = Join-Path $AdminRoot 'bin'
$Repo = 'ePlus-Game/phong-than-truyen-ky'
$Artifact = 'phongthan-pak-extractor-win32'
$TempRoot = Join-Path ([IO.Path]::GetTempPath()) ('pt-pak-install-' + [guid]::NewGuid().ToString('N'))
$ExtractDir = Join-Path $TempRoot 'extract'
$VerifyDir = Join-Path $TempRoot 'item-audit'
$Need = @('PakEntryExtract.exe', 'Engine.dll', 'LuaLibDll.dll')

function Assert-X86Pe([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 1024 -or $bytes[0] -ne 77 -or $bytes[1] -ne 90) {
        throw "Not a Windows EXE/DLL: $Path"
    }
    $pos = [BitConverter]::ToInt32($bytes,0x3c)
    if ($pos -lt 64 -or $pos+6 -ge $bytes.Length -or
        [BitConverter]::ToUInt32($bytes,$pos) -ne 0x00004550 -or
        [BitConverter]::ToUInt16($bytes,$pos+4) -ne 0x14c) {
        throw "Not a PE32 x86 executable: $Path"
    }
}
function Step([string]$Message) { Write-Host ('== ' + $Message) -ForegroundColor Cyan }

try {
    if (-not (Test-Path -LiteralPath $InstallerSource -PathType Leaf)) {
        throw "Missing installer catalog verifier: $InstallerSource"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ServerRoot 'package.ini') -PathType Leaf)) {
        throw "Missing Server/package.ini. PAK cannot be verified: $ServerRoot"
    }
    New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null
    if ($ZipPath) {
        Step '1/3 Open user-supplied official Actions artifact ZIP'
        $file = [IO.Path]::GetFullPath($ZipPath)
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            throw "ZIP not found: $file"
        }
        Expand-Archive -LiteralPath $file -DestinationPath $ExtractDir -Force
    } else {
        Step '1/3 Download official GitHub Actions artifact'
        $gh = Get-Command gh -ErrorAction SilentlyContinue
        if (-not $gh) {
            throw 'GitHub CLI (gh) not installed. Download the Actions artifact ZIP in your browser and run this script with -ZipPath "C:\path\phongthan-pak-extractor-win32.zip".'
        }
        if ($RunId -eq 0) {
            # Only select a successful build from the repository's MAIN branch,
            # not an arbitrary PR (which can contain untrusted executable code).
            $raw = @(& $gh.Source run list --repo $Repo --workflow windows-pak-extractor.yml --branch main --status success --limit 1 --json databaseId 2>&1)
            if ($LASTEXITCODE -ne 0) { throw "Cannot list GitHub builds. Sign in using gh auth login. $($raw -join ' ')" }
            $runs = @($raw -join [Environment]::NewLine | ConvertFrom-Json)
            if ($runs.Count -ne 1 -or -not $runs[0].databaseId) {
                throw 'No successful main-branch extractor build yet. Run the Windows PAK extractor workflow on main or download a reviewed artifact ZIP from Actions.'
            }
            $RunId = [long]$runs[0].databaseId
        }
        $run = @(& $gh.Source run view $RunId --repo $Repo --json headBranch,conclusion 2>&1)
        if ($LASTEXITCODE -ne 0) { throw "Cannot inspect GitHub run $RunId. $($run -join ' ')" }
        $meta = ($run -join [Environment]::NewLine) | ConvertFrom-Json
        if ($meta.headBranch -ne 'main' -or $meta.conclusion -ne 'success') {
            throw "Refusing run ${RunId}: only a successful MAIN-branch artifact can be installed automatically."
        }
        & $gh.Source run download $RunId --repo $Repo --name $Artifact --dir $ExtractDir
        if ($LASTEXITCODE -ne 0) { throw "Download failed for run $RunId. Check gh auth status or use -ZipPath." }
    }

    $resolved = @{}
    foreach($name in $Need) {
        $found = @(Get-ChildItem -LiteralPath $ExtractDir -File -Recurse | Where-Object { $_.Name -ieq $name })
        if ($found.Count -ne 1) {
            throw "Expected exactly one $name in the artifact; found $($found.Count). Do not use unrelated or incomplete binaries."
        }
        Assert-X86Pe $found[0].FullName
        $resolved[$name] = $found[0].FullName
    }

    Step '2/3 Verify ALL 15 actual PAK tables in a disposable directory'
    $result = & $InstallerSource -ServerRoot $ServerRoot -ItemDir $VerifyDir -PakTool $resolved['PakEntryExtract.exe']
    if (-not $result -or -not $result.PakVerified -or $result.Tables -ne 15) {
        $details = if ($result -and $result.Issues) { @($result.Issues) -join ' | ' } else { 'PAK verification returned no details' }
        throw "PAK NOT VERIFIED; no tool files installed. $details"
    }
    Step '3/3 Install verified reader into AdminWeb/bin'
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    $backup = Join-Path $AdminRoot ('bin-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    $hasExisting = @($Need | Where-Object { Test-Path -LiteralPath (Join-Path $Target $_) -PathType Leaf }).Count -gt 0
    if ($hasExisting) {
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        foreach ($name in $Need) {
            $old = Join-Path $Target $name
            if (Test-Path -LiteralPath $old -PathType Leaf) {
                Copy-Item -LiteralPath $old -Destination (Join-Path $backup $name) -Force
            }
        }
        Write-Host "Previous tool backed up to $backup" -ForegroundColor Yellow
    }
    foreach($name in $Need) {
        Copy-Item -LiteralPath $resolved[$name] -Destination (Join-Path $Target $name) -Force
    }
    Write-Host ''
    Write-Host 'PAK VERIFIED: 15/15. All three tool files installed successfully.' -ForegroundColor Green
    Write-Host "Admin tool directory: $Target"
    Write-Host 'Close and re-open ONLY Web Admin to enable item grants. SQL and game servers remain running.'
} catch {
    Write-Host ''
    Write-Host ('PAK SETUP FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Nothing was changed in game PAK, Server DLL or LocalDB.' -ForegroundColor Yellow
    throw
} finally {
    if (Test-Path -LiteralPath $TempRoot -PathType Container) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
