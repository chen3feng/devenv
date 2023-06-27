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
if '%cd%' == '%PWD%' exit /b

set OLDPWD=%PWD%
set PWD=%cd%
call %~dp0git\update-prompt.cmd
