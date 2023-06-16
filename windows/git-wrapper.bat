@echo off

git.exe %*
set /a exitcode=%errorlevel%

call %~dp0update-git-prompt.cmd

exit /B %exitcode%
