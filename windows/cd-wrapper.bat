@echo off
if '%*'=='' cd & exit /b
if '%*'=='-' (
	if '%OLDPWD%' neq '' (
		cd /d %OLDPWD%
		call %~dp0update-git-prompt.cmd
	)
    set OLDPWD="%cd%"
) else if '%*'=='~' (
	cd /d "%USERPROFILE%"
) else (
    cd /d %*
    if not errorlevel 1 (
		set OLDPWD="%cd%"
		call %~dp0update-git-prompt.cmd
	)
)
