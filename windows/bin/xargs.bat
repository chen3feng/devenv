@echo off
:: example:   git branch | grep -v "develop" | xargs git branch -D
:: example    xargs -a input.txt echo
:: https://helloacm.com/simple-xargs-batch-implementation-for-windows/

setlocal enabledelayedexpansion

set cmd=
set file='more'

:: read from file
if "%1" == "-a" (
    if "%2" == "" (
        echo Correct Usage: %0 -a Input.txt command
        goto :EOF
    )
    set file=%2
    shift
    shift
    goto start
)

:: read from stdin
set cmd=%1
shift

:start
    if [%1] == [] goto start1
    set cmd=%cmd% %1
    shift
    goto start

:start1
    set args=
    for /F "tokens=*" %%a in (!file!) do (
        if [!args!] == [] (
            set "new_args=%%a"
        ) else (
            set "new_args=!args! %%a"
        )
        call :strlen len "!new_args!"
        :: https://learn.microsoft.com/en-us/troubleshoot/windows-client/shell-experience/command-line-string-limitation
        if !len! gtr 8000 (
            if not [!args!] == [] (
                call %cmd% !args!
            )
            set "args=%%a"
        ) else (
            set "args=!new_args!"
        )
    )
    if not [!args!] == [] (
        call %cmd% !args!
    )


goto :EOF


::https://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file
REM ********* function *****************************
:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    (set^ tmp=!%~2!)
    if defined tmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!tmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "tmp=!tmp:~%%P!"
            )
        )
    ) else (
        set len=0
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)
