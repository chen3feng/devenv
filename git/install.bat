@echo off

setlocal enabledelayedexpansion

for /f %%i in ('git config --global core.hookspath') do set old=%%i
set hookspath=%~dp0hooks
set hookspath=%hookspath:\=/%

if not [%old%] == [] (
	if not [%hookspath%] == [%old%] (
		choice /M "global 'core.hooksPath' is already set to '%old%', do you want to overrite it with '%hookspath%'? (y/N) "
		if not !errorlevel! == 1 (
			exit /b 1
		)
	) else (
		exit /b
	)
)

git config --global core.hooksPath %hookspath%
echo git global hook '%hookspath%' is installed.
