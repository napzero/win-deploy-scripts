@echo off
cd /d %0\.. & color 0e & setlocal

::cmd /c install.bat | wtee %TEMP%\java_deployment.log

ECHO One moment please...
PowerShell.exe -Command "cmd /c install.bat | tee-object -filepath $env:TEMP\java_deployment.log"

color & endlocal & EXIT 0