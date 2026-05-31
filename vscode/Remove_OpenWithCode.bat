@echo off
:: Remove the "Open with Code" context menu entries added by Add_OpenWithCode.bat.
:: Operates on HKCU only, so no administrator rights are required.

setlocal

reg delete "HKCU\Software\Classes\*\shell\OpenWithCode" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\OpenWithCode" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\OpenWithCode" /f >nul 2>&1

echo Removed "Open with Code" from the context menu.
