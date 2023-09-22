@echo off

set PATH=%PATH%;%~dp0bin

doskey /macrofile=%~dp0doskey.macros
doskey git=%~dp0git\wrapper.bat $*

:: Git subcommands
set git_commands=%~dp0git\commands.bat
:: git alias external command only accept unix path
call :to_unix_path git_commands
git config --global alias.finish "!%git_commands% finish"
set git_commands=

::CD Aliases
::https://stackoverflow.com/questions/9228950/what-is-the-alternative-for-users-home-directory-on-windows-command-prompt
::https://stackoverflow.com/questions/48189935/how-can-i-return-to-the-previous-directory-in-windows-command-prompt
doskey cd=%~dp0cd-wrapper.bat $*
doskey .=cd
doskey ..=%~dp0cd-wrapper.bat ..
doskey ...=%~dp0cd-wrapper.bat ..\..
doskey ....=%~dp0cd-wrapper.bat ..\..\..
doskey .....=%~dp0cd-wrapper.bat ..\..\..\..
doskey ......=%~dp0cd-wrapper.bat ..\..\..\..\..
doskey .......=%~dp0cd-wrapper.bat ..\..\..\..\..\..
doskey ........=%~dp0cd-wrapper.bat ..\..\..\..\..\..\..
doskey .........=%~dp0cd-wrapper.bat ..\..\..\..\..\..\..\..


exit /b 0


:: Convert a file path from dos form to unix form
:to_unix_path
call set to_unix_path_val=%%%1%%%
call set %1="%to_unix_path_val:\=/%"
set to_unix_path_val=
exit /b 0
