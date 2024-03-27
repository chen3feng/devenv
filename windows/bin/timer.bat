@REM Calculate time of a command
@echo off

setlocal

rem Get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

REM Execute the command
call %*
set err=%errorlevel%

rem Get end time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

rem Get elapsed time:
set /A elapsed=end-start

rem Show elapsed time:
set /A hour=elapsed/(60*60*100), rest=elapsed%%(60*60*100), min=rest/(60*100), rest%%=60*100, sec=rest/100, cc=rest%%100

if %min% lss 10 (set mm=0%min%) else (set mm=%min%)
if %sec% lss 10 (set ss=0%sec%) else (set ss=%sec%)
if %cc% lss 10 set cc=0%cc%

if %hour% neq 0 (
    echo %h%:%mm%:%ss%.%cc%s
) else if %min% neq 0 (
    echo %min%:%ss%.%cc%s
) else (
    echo %sec%.%cc%s
)

exit /b %err%
