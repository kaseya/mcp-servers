@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-claude-code.ps1"
set "installerExit=%ERRORLEVEL%"
pause
exit /b %installerExit%
