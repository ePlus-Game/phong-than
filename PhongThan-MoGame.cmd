@echo off
setlocal
rem Mo client Phong Than. Chi khoi dong neu Game.exe ton tai va client patch thanh cong.
set "CLIENT_DIR=%~dp0PhongThanRuntime-Staging\Client"
set "CLIENT_EXE=%CLIENT_DIR%\Game.exe"
if not exist "%CLIENT_EXE%" (
  echo LOI: Khong tim thay Game.exe trong "%CLIENT_DIR%".
  exit /b 2
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AdminWeb\PhongThan-ClientPatch.ps1"
if errorlevel 1 (
  echo LOI: Client patch that bai. Game se khong duoc khoi dong.
  exit /b 1
)
set "__COMPAT_LAYER=HIGHDPIAWARE"
start "" /D "%CLIENT_DIR%" "%CLIENT_EXE%"
if errorlevel 1 (
  echo LOI: Khong khoi dong duoc Game.exe.
  exit /b 1
)
exit /b 0
