@echo off
cd /d %0\.. & color 0e & setlocal

::ECHO One moment please... & PowerShell.exe -Command "cmd /c import.bat | tee-object -filepath %CD%\logs\import.log"

cmd /c import.bat

color & endlocal & EXIT 0