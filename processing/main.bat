@echo off
cd /d %0\.. & color 0e & setlocal

ECHO Installing Processing.org software...
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File ".\install.ps1"


color & endlocal & EXIT 0