@echo off
::activesetup template v002
cd /d %0\..
setlocal
IF [%1]==[] (SET ACCOUNT=%userprofile%) ELSE (SET ACCOUNT=%1)



SET FILEPATH=AppData\LocalLow\Apple Computer\QuickTime
SET FILETOINSTALL=QuickTime.qtp




if NOT exist "%ACCOUNT%\%FILEPATH%\%FILETOINSTALL%" (
mkdir "%ACCOUNT%\%FILEPATH%"
copy %FILETOINSTALL% "%ACCOUNT%\%FILEPATH%\%FILETOINSTALL%" /V
REG IMPORT HKCU.reg
)






endlocal
EXIT 0