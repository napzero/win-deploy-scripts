@echo off
setlocal
cd /d %0\..
color 0e

::These SET lines must be verified with each update.

SET _VER=221

SET _j64file=jdk-8u%_VER%-windows-i586.exe
SET _j32file=jdk-8u%_VER%-windows-x64.exe

SET "_jdkpath=C:\Program Files\Java\jdk1.8.0_%_VER%\bin"

set "jTestFile=1.8.0_%_VER%\bin\java.exe"




For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/" %%a in ('time /t') do (set mytime=%%a%%b)
ECHO. & ECHO JAVA DEVELOPMENT KIT 8u%_VER%
echo Beginning new deployment.
echo %mydate% %mytime%


ECHO.
ECHO Simple binary check of installation status...
set allbinfound=1
if NOT exist "%ProgramFiles%\Java\jdk%jTestFile%" ( set allbinfound=0 )
if NOT exist "%ProgramFiles%\Java\jre%jTestFile%" ( set allbinfound=0 )
::
if defined ProgramFiles(x86) (
if NOT exist "%ProgramFiles(x86)%\Java\jdk%jTestFile%" set allbinfound=0
if NOT exist "%ProgramFiles(x86)%\Java\jre%jTestFile%" set allbinfound=0
)
::
IF %allbinfound% EQU 1 call:verifyPath
IF %allbinfound% EQU 1 color 0a & ECHO JAVA Appears to be installed and up-to-date! Exiting... & timeout 3 & EXIT 0


call:killUpdates

ECHO. & ECHO Uninstalling older Java 8 products...
wmic product where "Name like '%%Java SE Development Kit 8%%'" call uninstall /nointeractive
wmic product where "Name like '%%Java 8%%'" call uninstall /nointeractive


ECHO. & ECHO Installing JDK 8u%_VER%...

%_j32file% INSTALLCFG=%CD%\jdk_configuration_file
%_j64file% INSTALLCFG=%CD%\jdk_configuration_file




ECHO Cleaning system PATH variable...
PowerShell.exe -Command "[System.Environment]::SetEnvironmentVariable('Path',($env:path -split ';' | where {$_ -and (Test-Path $_  )}| select-object -unique) -join ';','Machine')"


::Search for _jdkpath in PATH variable. If NOT found, apply.
echo %path% | find "%_jdkpath%" || SETX PATH "%PATH%;%_jdkpath%" /M


call:killUpdates


ECHO End of script reached.
color
endlocal
EXIT 0

:verifyPath
echo %path% | find "%_jdkpath%" || SETX PATH "%PATH%;%_jdkpath%" /M
GOTO:EOF

:killUpdates
ECHO Disabling updates...
taskkill /f /im jusched.exe
taskkill /f /im jucheck.exe
taskkill /f /im jaureg.exe
rmdir /s /q "%ProgramFiles(x86)%\Common Files\Java\Java Update"
rmdir /s /q "%ProgramFiles%\Common Files\Java\Java Update"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f
GOTO:EOF