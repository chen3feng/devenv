@echo off

if [%1] == [finish] (
	call :finish %*
) else (
	git.exe %*
)

goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: function finish(args...)
:finish
	setlocal
	shift
	if "%1" == "--help" (
		call :finish_help
		exit /b
	)
	set CURRENT_BRANCH=
	set DEFAULT_BRANCH=

	for /f "tokens=1" %%I in ('git.exe rev-parse --abbrev-ref HEAD 2^> NUL') do set CURRENT_BRANCH=%%I
	for /f "tokens=1" %%I in ('git.exe symbolic-ref -q HEAD --short 2^> NUL') do set DEFAULT_BRANCH=%%I

	if "%CURRENT_BRANCH%" == "%DEFAULT_BRANCH%" (
		echo You are already in the mainline branch.
		exit /b 1
	)

	git.exe diff --name-status --exit-code
	if errorlevel 1 (
		echo You have uncommitted local changes.
		exit /b 1
	)

	git.exe checkout %DEFAULT_BRANCH%
	:: can be --rebase ?
	shift
	git.exe pull
	git.exe branch -D %DEFAULT_BRANCH%
exit /b


:: function finish_help()
:finish_help
	echo git finish: Finish your current working branch after it is merged to the mainline remotely.
	echo It switches to the mainline branch, executes git pull, then deletes the original working branch.
exit /b
