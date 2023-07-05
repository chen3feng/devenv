@echo off
powershell -Command "Start-Process cmd -Verb RunAs -ArgumentList '/c cd /d %CD% && %*'"
@echo on
