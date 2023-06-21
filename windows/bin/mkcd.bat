@echo off

if not "%2" == "" (
	echo Too much arguments
	exit /b 1
)

if "%1" == "" (
	mkdir
) else (
	if not exist "%1" (
		mkdir "%1"
	)
	if errorlevel 0 (
		cd "%1"
	)
)