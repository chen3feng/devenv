::@echo off
setlocal enabledelayedexpansion

set dir=
set force=
set interactive=
set recursive=
set verbose=
set paths=

for /f "delims= " %%x in ("%*") do (
    echo XXX [%%x]
)
exit /b
    ::call :parse_one_arg [%%x]
echo dir=%dir%
echo force=%force%
echo interactive=%interactive%
echo recursive=%recursive%
echo verbose=%verbose%
echo paths=%paths%


exit /b

:: Pass all arguments to PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0RemoveItemToRecycleBin.ps1" %*

:: functions

:parse_one_arg
:: Parse options starts with --
echo %~1 | findstr /R "^\[--[a-z]." >nul
if not errorlevel 1 (
    if %~1 == [--help] (
        call :show-usage
        goto :EOF
    ) else if %~1 == [--version] (
        echo rm ^(with recycle bin support^) 1.0
        echo Written by chen3feng
        goto :EOF
    ) else if %~1 == [--dir] (
        set dir=--dir
    ) else if %~1 == [--force] (
        set force=--force
    ) else if %~1 == [--interactive] (
        set interactive=%1
    ) else if %~1 == [--recursive] (
        set recursive=--recursive
    ) else if %~1 == [--verbose] (
        set verbose=--verbose
    ) else (
        echo Invalid argument %1
    )
    exit /b
)

:: Parse options starts with -
echo %~1 | findstr /R "^-[a-z]." >nul
if not errorlevel 1 (
    echo - %1
    exit /b
)
set "paths=%paths% %1"
exit  /b

:show-usage
echo Usage: rm [OPTION]... [FILE]...
echo Remove (unlink) the FILE(s).
echo.
echo   -f, --force           ignore nonexistent files and arguments, never prompt
echo   -i                    prompt before every removal
echo   -I                    prompt once before removing more than three files, or
echo                           when removing recursively; less intrusive than -i,
echo                           while still giving protection against most mistakes
echo       --interactive[=WHEN]  prompt according to WHEN: never, once (-I), or
echo                           always (-i); without WHEN, prompt always
echo       --no-preserve-root  do not treat '/' specially
echo       --preserve-root[=all]  do not remove '/' (default);
echo                               with 'all', reject any command line argument
echo                               on a separate device from its parent
echo   -r, -R, --recursive   remove directories and their contents recursively
echo   -d, --dir             remove empty directories
echo   -v, --verbose         explain what is being done
echo       --help     display this help and exit
echo       --version  output version information and exit
echo.
echo By default, rm does not remove directories.  Use the --recursive (-r or -R)
echo option to remove each listed directory, too, along with all of its contents.
echo.
echo To remove a file whose name starts with a '-', for example '-foo',
echo use one of these commands:
echo   rm -- -foo
echo.
echo   rm ./-foo
goto :EOF

endlocal
