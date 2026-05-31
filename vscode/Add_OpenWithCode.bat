@echo off
:: Add "Open with Code" to the right-click context menu for the CURRENT user.
::
:: Writes to HKCU\Software\Classes (which Windows merges into HKCR), so it needs
:: NO administrator rights, consistent with the other reg-based installers in
:: this repo. Run Remove_OpenWithCode.bat to undo.

setlocal

:: Detect VS Code, per-user install first then system-wide.
set "vscode="
if exist "%LocalAppData%\Programs\Microsoft VS Code\Code.exe" set "vscode=%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" set "vscode=%ProgramFiles%\Microsoft VS Code\Code.exe"

if not defined vscode (
    echo Error: VS Code not found in the default locations.
    exit /b 1
)
echo Found VS Code at: %vscode%

:: On a selected file or folder, %1 is the clicked item.
reg add "HKCU\Software\Classes\*\shell\OpenWithCode" /ve /d "Open with Code" /f >nul
reg add "HKCU\Software\Classes\*\shell\OpenWithCode" /v Icon /d "\"%vscode%\",0" /f >nul
reg add "HKCU\Software\Classes\*\shell\OpenWithCode\command" /ve /d "\"%vscode%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\shell\OpenWithCode" /ve /d "Open with Code" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\OpenWithCode" /v Icon /d "\"%vscode%\",0" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\OpenWithCode\command" /ve /d "\"%vscode%\" \"%%1\"" /f >nul

:: On a folder background, %V is the current folder.
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenWithCode" /ve /d "Open with Code" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenWithCode" /v Icon /d "\"%vscode%\",0" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenWithCode\command" /ve /d "\"%vscode%\" \"%%V\"" /f >nul

echo Success! "Open with Code" added to the context menu.
