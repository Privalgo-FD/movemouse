@echo off
REM Simple wrapper to run the PowerShell packaging script on Windows
SET SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%package-release.ps1" %*
