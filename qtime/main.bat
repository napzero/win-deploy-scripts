@echo off
cd /d %0\..
color 0e
CLS
ECHO INSTALLING QUICKTIME

::NOTE - AppleSoftwareUpdate is necessary.
msiexec /i AppleApplicationSupport.msi /quiet /norestart
msiexec /i AppleSoftwareUpdate.msi /quiet /norestart
msiexec /i QuickTime.msi /quiet DESKTOP_SHORTCUTS=NO SCHEDULE_ASUW=0 ASUWINSTALLED=0 /norestart
schtasks /delete /tn "Apple\AppleSoftwareUpdate" /f


SET CCC_DEPLOY_FOLDER=CCCdeploy-QuickTime
ECHO Installing Activesetup components
mkdir %SystemDrive%\ProgramData\%CCC_DEPLOY_FOLDER%
robocopy PROGDATA %SystemDrive%\ProgramData\%CCC_DEPLOY_FOLDER%\ /MIR
REG IMPORT activesetup.reg
)


::if NOT EXIST "%programfiles%/QuickTime/QuickTimePlayer.exe" (echo retrying
::msiexec /i QuickTime.msi /quiet DESKTOP_SHORTCUTS=NO SCHEDULE_ASUW=0 ASUWINSTALLED=0 /norestart
::goto:EOF)

color
EXIT 0