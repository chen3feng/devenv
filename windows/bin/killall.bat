@echo off

setlocal EnableDelayedExpansion

if [%*] == [] (
    echo Usage: killall [-9 ] NAME...
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
    set "args=!args! /im %%t"
)

taskkill %force% %args%

goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: function :Usage()
:Usage
    echo killall [-9] NAME...
    echo    Send a signal to a process.
    echo.
    echo    Send the processes identified by name signal to terminate.
    echo.
    echo    Options:
    echo      -9        Specifies to forcefully terminate the process(es).
exit /b
