@echo off
doskey /macrofile=%~dp0doskey.macros
doskey git=%~dp0git-wrapper.bat $*

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
