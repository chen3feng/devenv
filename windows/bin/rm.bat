@echo off

:: Pass all arguments to PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0RemoveItemToRecycleBin.ps1" %*
