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

:: Disable autocrlf
:: https://stackoverflow.com/questions/20168639/git-commit-get-fatal-error-fatal-crlf-would-be-replaced-by-lf-in
:: https://markentier.tech/posts/2021/10/autocrlf-true-considered-harmful/
git config --global core.autocrlf false

:: Check whether file contains mixed LF and CRLF
:: git config --global core.safecrlf false
:: can also be true and warn
