@echo off

setlocal

if not exist "%~1" type nul >>"%~1"& goto :eof
set _ATTRIBUTES=%~a1
if "%~a1"=="%_ATTRIBUTES:r=%" (copy "%~1"+,, >nul) else attrib -r "%~1" & copy "%~1"+,, & attrib +r "%~1"

endlocal
