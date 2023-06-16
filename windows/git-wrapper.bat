:: Show branch name in command prompt. See https://stackoverflow.com/a/52411694

@echo off

git.exe %*
set /a exitcode=%errorlevel%

set GITBRANCH=
for /f "tokens=2" %%I in ('git.exe branch 2^> NUL ^| findstr /b "* "') do set GITBRANCH=%%I

if "%GITBRANCH%" == "" (
    prompt $P$G 
) else (
    prompt $P $C$E[1;7;32;47m%GITBRANCH%$E[0m$F $G 
)

exit /B %exitcode%
