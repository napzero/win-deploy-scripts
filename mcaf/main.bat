@echo off
cd /d %0\..
color 0e

SET targetfile="%SystemDrive%\Program Files\Common Files\McAfee\SystemCore\mcshield.exe"
IF EXIST %targetfile% (CLS & color 0a & ECHO. & ECHO McAfee Framepack already installed! Exiting... & timeout 9 & EXIT 0) 

echo Silently installing McAfee Framepack...
FramePkg.exe /install=agent /silent

copy mcmonitor.bat %temp% /V
start "" %temp%\mcmonitor.bat

exit 0