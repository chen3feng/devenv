@echo off
:: Pass all arguments to PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0RemoveItemToRecycleBin.ps1" %*
