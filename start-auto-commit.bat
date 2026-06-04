@echo off
REM Start the auto-commit watcher
REM This script will monitor your repository for changes and automatically commit and push them

cd /d "c:\Users\laven\repos\Facebook-ads-lose-effiency-after-audience-saturation\Facebook-ads-lose-efficiency-after-audience-saturation"

echo.
echo ========================================
echo   Auto-Commit Watcher Startup
echo ========================================
echo.
echo Starting PowerShell auto-commit watcher...
echo.

REM Run PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "auto-commit-watcher.ps1" -IntervalSeconds 30 -CommitMessage "Auto-commit: Changes saved"

pause
