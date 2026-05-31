reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "%~dp0autorun.bat" /f

echo Install PowerShell prompt
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\install.ps1"
where pwsh >nul 2>nul && pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\install.ps1"
