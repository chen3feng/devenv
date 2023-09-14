@echo off
setlocal

if "%1" == "--help" (
    call :ShowUsage
    exit /b 0
)

if "%1" == "" (
    set kernel_name=1
) else (
    for %%X in (%*) do (
        for %%A in ("-s" "--kernel-name") do if "%%X"==%%A set kernel_name=1
        for %%A in ("-a" "--all") do if "%%X"==%%A set all=1
        for %%A in ("-n" "--node-name") do if "%%X"==%%A set nodename=1
        for %%A in ("-m" "--machine") do if "%%X"==%%A set machine=1
        for %%A in ("-o" "--operating-system") do if "%%X"==%%A set operating_system=1
        for %%A in ("-r" "--kernel-release") do if "%%X"==%%A set kernel_release=1
    )
)

for /f "usebackq" %%i in (`hostname`) do set HOSTNAME=%%i
for /f "tokens=* usebackq" %%i in (`ver`) do set VER=%%i
for /f %%i in ("%PROCESSOR_IDENTIFIER%") do set PROCESSOR=%%i

if "%all%" == "1" (
    echo %OS% %USERNAME% %HOSTNAME% %PROCESSOR% %VER%
    exit /b 0
)

set msg=
if "%operating_system%" == "1" call :AppendVariable msg %OS%
if "%nodename%" == "1" call :AppendVariable msg %HOSTNAME%
if "%machine%" == "1" call :AppendVariable msg %PROCESSOR%
if "%kernel_name%" == "1" call :AppendVariable msg %OS%
if "%kernel_release%" == "1" call :AppendVariable msg "%VER%"
echo %msg%

goto :EOF


:ShowUsage
echo Usage: uname [OPTION]...
echo.
echo Print certain system information.  With no OPTION, same as -s.
echo.
echo   -a, --all                print all information, in the following order,
echo                              except omit -p and -i if unknown:
echo   -s, --kernel-name        print the kernel name
echo   -n, --nodename           print the network node hostname
echo   -r, --kernel-release     print the kernel release
echo   -v, --kernel-version     print the kernel version
echo   -m, --machine            print the machine hardware name
echo   -o, --operating-system   print the operating system
echo       --help     display this help and exit
echo       --version  output version information and exit
exit /b 0

:: :Append varname value
:AppendVariable
call set "AppendVariable_value=%%%~1%%%"
if "%AppendVariable_value%" == "" (
    call set "%~1=%~2"
) else (
    call set "%~1=%%%~1%% %~2"
)
exit /b 0


endlocal
