@echo off

setlocal EnableDelayedExpansion

if "%1" == "" (
    echo kill: usage: kill [-9 ] pid...
    exit /b
)

set targets=

for %%I in (%*) do (
    if "%%I" == "--help" (
        call :Usage
        exit /b
    ) else if "%%I" == "-9" (
        set "force=/F"
    ) else (
        if defined targets (
            set "targets=!targets! %%I"
        ) else (
            set "targets=%%I"
        )
    )
)

set args=

for %%t in (%targets%) do (
    echo {%%t}|findstr /R "{[0-9][0-9]*}" > nul
    if errorlevel 1 (
        set "args=!args! /im %%t"
    ) else (
        set "args=!args! /pid %%t"
    )
)

taskkill %force% %args%

endlocal

goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Usage
echo kill: kill [-9] pid...
echo    Send a signal to a job.
echo.
echo    Send the processes identified by PID signal to terminate.
echo.
echo    Options:
echo      -9        Specifies to forcefully terminate the process(es).
exit /b
