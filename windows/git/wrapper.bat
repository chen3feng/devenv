@echo off

call %~dp0commands.bat %*
set /a exitcode=%errorlevel%

call %~dp0update-prompt.cmd

exit /B %exitcode%
