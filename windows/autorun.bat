@echo off

:: In case of the window directory was removed from PATH by something like Unreal Engine builder script.
::if not [%SESSIONNAME%] == [] exit /b 0

:: In case of cmd.exe is not started from a console process, but it's grandpa process is cmd.exe,
:: the doskey is not inherited, so it should be set every time before the SHLVL checking.
call :init_doskey

:: Avoid nested initialization.
if not [%SHLVL%] == [] goto :Nested
set SHLVL=1

set PATH=%PATH%;%~dp0bin

call :init_git

goto :EOF

:Nested
set /a SHLVL=%SHLVL% + 1
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Functions

:: function init_git()
:init_git
    setlocal
    :: Git subcommands
    set git_commands=%~dp0git\commands.bat
    :: git alias external command only accept unix path
    call :to_unix_path git_commands
    git.exe config --global --replace-all alias.finish "!%git_commands% finish" 2>nul
    set git_commands=
exit /b


:: function to_unix_path(&path)
:: Convert a file path from dos form to unix form
:to_unix_path
    setlocal
    call set unix_path=%%%1%%
    set "unix_path=%unix_path:\=/%"
    endlocal & set %~1=%unix_path%
exit /b


:: function init_doskey()
:init_doskey
    setlocal
    doskey /? >nul 2>nul
    if errorlevel 1 exit /b
    doskey /macrofile=%~dp0doskey.macros 2>nul
    doskey git=%~dp0git\wrapper.bat $* 2>nul

    ::CD Aliases
    ::https://stackoverflow.com/questions/9228950/what-is-the-alternative-for-users-home-directory-on-windows-command-prompt
    ::https://stackoverflow.com/questions/48189935/how-can-i-return-to-the-previous-directory-in-windows-command-prompt
    doskey cd=%~dp0cd-wrapper.bat $*
    doskey cd..=%~dp0cd-wrapper.bat ..
    doskey .=cd
    doskey ..=%~dp0cd-wrapper.bat ..
    doskey ...=%~dp0cd-wrapper.bat ..\..
    doskey ....=%~dp0cd-wrapper.bat ..\..\..
    doskey .....=%~dp0cd-wrapper.bat ..\..\..\..
    doskey ......=%~dp0cd-wrapper.bat ..\..\..\..\..
    doskey .......=%~dp0cd-wrapper.bat ..\..\..\..\..\..
    doskey ........=%~dp0cd-wrapper.bat ..\..\..\..\..\..\..
    doskey .........=%~dp0cd-wrapper.bat ..\..\..\..\..\..\..\..
exit /b
