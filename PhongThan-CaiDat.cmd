@echo off
setlocal
rem Cai dat server Phong Than tren may moi: cai SQL LocalDB + khoi phuc database account.
title Phong Than - Cai dat server
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0AdminWeb\PhongThan-Setup.ps1" -Step all
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" echo LOI: Cai dat that bai. Xem thong bao o tren.
pause
exit /b %EXIT_CODE%
