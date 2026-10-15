@echo off
setlocal
cd /d "%~dp0.."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Pak-Extractor.ps1" %*
set "RESULT=%ERRORLEVEL%"
echo.
if not "%RESULT%"=="0" (echo Kiem tra loi o tren. Web Admin van hoat dong, nhung phat item van bi khoa.) else (echo PAK da xac minh. Dong va mo lai CUA SO Web Admin de ap dung.)
pause
exit /b %RESULT%
