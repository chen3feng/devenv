@echo off

if '%*'=='' cd && exit /b

set PWD=%cd%

if '%*'=='-' (
	if '%OLDPWD%' == '' exit /b
	cd /d %OLDPWD%
) else if '%*'=='~' (
	cd /d "%USERPROFILE%"
) else (
	cd /d %*
)

if errorlevel 1 exit /b %errorlevel%
if '%cd%' == '%pwd%' exit /b

set OLDPWD=%pwd%
call %~dp0git\update-prompt.cmd
