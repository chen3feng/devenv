@echo off

git.exe %*
set /a exitcode=%errorlevel%

call %~dp0update-prompt.cmd

exit /B %exitcode%
