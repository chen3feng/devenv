@echo off

:: Usage:
::   :: Switch alternative screen
::   alt-screen
::
::   :: Enter alternative screen
::   alt-screen enter
::
::   :: Leave alternative screen
::   alt-screen leave

setlocal

for /f %%A in ('echo prompt $E ^| cmd') do ( set "ESC=%%A" )

if "%1" == "enter" (
    call :enter_alt_screen
) else if "%1" == "leave" (
    call :leave_alt_screen
) else (
    if "%IN_ALT_SCREEN%" == "1" (
        call :leave_alt_screen
    ) else (
        call :enter_alt_screen
    )
)

endlocal & set "IN_ALT_SCREEN=%IN_ALT_SCREEN%"

goto :EOF

:enter_alt_screen
    echo|set /p=%ESC%[?1049h
    set "IN_ALT_SCREEN=1"
exit /b

:leave_alt_screen
    echo|set /p=%ESC%[?1049l
    set "IN_ALT_SCREEN=0"
exit /b
