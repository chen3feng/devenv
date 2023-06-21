@echo off

if "%1" == "finish" (
	call :finish %*
) else (
	echo Unknown subcommand %1 1>&2
)

goto :eof


:finish
set CURRENT_BRANCH=
set DEFAULT_BRANCH=

for /f "tokens=1" %%I in ('git.exe rev-parse --abbrev-ref HEAD 2^> NUL') do set CURRENT_BRANCH=%%I
for /f "tokens=1" %%I in ('git.exe symbolic-ref refs/remotes/origin/HEAD 2^> NUL') do set DEFAULT_BRANCH=%%I
set DEFAULT_BRANCH=%DEFAULT_BRANCH:refs/remotes/origin/=%

echo CURRENT_BRANCH:%CURRENT_BRANCH%
echo DEFAULT_BRANCH:%DEFAULT_BRANCH%
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
git.exe pull %*
goto :eof
