@echo off
::mcmonitor.bat v003 by Matt Podowski
::usage:
::mcmonitor (no arguments)
::mcmonitor -log (writes to logfile)
::mcmonitor -nopause (exits immediately after McAfee is deployed, writes to log. Useful for chaining with another script)
::
::Use with another script:
::copy mcmonitor.bat %temp% /V
::start "" %temp%\mcmonitor.bat
::OR
::cmd /C %temp%\mcmonitor.bat -nopause

cd /d %0\..
setlocal
IF [%1]==[-log] (SET writelog=yes) ELSE (SET writelog=no)
IF [%1]==[-nopause] (SET pause=no & SET writelog=yes) ELSE (SET pause=yes)

SET targetfile="%SystemDrive%\Program Files\Common Files\McAfee\SystemCore\mcshield.exe"
SET logfile=%SystemDrive%\temp\mcmonitor.log
SET hours=0
SET minutes=0
color 06

::Check every minute if targetfile exists. Count how many minutes have passed.
::When it exists, display green text DEPLOYED and final time.

setlocal enabledelayedexpansion
:wait
IF NOT EXIST %targetfile% (CLS & ECHO.
IF %minutes%==60 (
SET /A hours=hours+1 & SET minutes=0 )
ECHO McAfee AntiVirus not deployed yet. Waited !hours! hours and !minutes! minutes. & timeout 60 /nobreak & SET /A minutes=minutes+1
goto:wait)

setlocal disabledelayedexpansion
IF EXIST %targetfile% (CLS & color 0a & ECHO. & ECHO             AntiVirus is deployed! Waited %hours% hours and %minutes% minutes.
echo.
:: font Name: Banner3 http://patorjk.com/software/taag
echo            ##     ##  ######     ###    ######## ######## ########
echo            ###   ### ##    ##   ## ##   ##       ##       ##
echo            #### #### ##        ##   ##  ##       ##       ##
echo            ## ### ## ##       ##     ## ######   ######   ######
echo            ##     ## ##       ######### ##       ##       ##
echo            ##     ## ##    ## ##     ## ##       ##       ##
echo            ##     ##  ######  ##     ## ##       ######## ########
echo.
echo  ########  ######## ########  ##        #######  ##    ## ######## ########
echo  ##     ## ##       ##     ## ##       ##     ##  ##  ##  ##       ##     ##
echo  ##     ## ##       ##     ## ##       ##     ##   ####   ##       ##     ##
echo  ##     ## ######   ########  ##       ##     ##    ##    ######   ##     ##
echo  ##     ## ##       ##        ##       ##     ##    ##    ##       ##     ##
echo  ##     ## ##       ##        ##       ##     ##    ##    ##       ##     ##
echo  ########  ######## ##        ########  #######     ##    ######## ########
echo.
echo.
echo.
echo.
echo.
)
IF %writelog%==yes call:writeToLog
IF %pause%==yes pause
endlocal
exit 0

:writeToLog
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
ECHO McMonitor.bat v003 waited %hours% hours and %minutes% minutes for McAfee to deploy. >> %logfile% & ECHO %mydate%_%mytime% >> %logfile% & ECHO. >> %logfile%
GOTO:EOF