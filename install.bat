@echo off

echo Install for git
call %~dp0git\install.bat

echo Install for cmd.exe
call %~dp0windows\install.bat
