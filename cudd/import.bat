@echo off
cd /d %0\.. 
color 0e
setlocal


::Loop over local drives (skip C), find sources (with \users folder), and prompt for drive selection.

::Loop over profiles (preemptive):
::	store profile name
::	if profile exists at target, append warning, set warning variable, and continue.
::	display variable, continue loop
::If warning variable set, display final warning and allow choice of action. (s)kip, or (a)rchive copy (username.old).

::Prompt for One or All mode.

::One mode:
::Prompt for user. 
::	call:importUserProfile user
::goto End
::
::All mode:
::Loop over profiles. For each user:
::	call:importUserProfile user
::goto End

::importUserProfile:
::	if profile matches a name on the exclude list [public, administrator, etc], skip.
::	if profile exists on targetDrive, do (skip or archive), complete loop.
::	else,
::	robocopy over the profile (filter out temp files and other unwanted)
::	get registry values from source hive and import them
::GOTO:END

::Unload source registry.
::Done?

::ECHO This script is not ready! If you ran this by accident, please close it! & pause


::setup variables
SET LogDir=%CD%\logs
SET LogFile=%LogDir%\LOG.log
SET targetUsers=%SystemDrive%\Users

set _existingProfileWarning=0
set _existingProfileMode=s

::prep other things
if not exist %LogDir% mkdir %LogDir%

ECHO version 001
ECHO ################################################################################################
ECHO    REMINDERS!
ECHO    This script copies files and imports registry data from an offline Windows drive. 
ECHO    *Do not import profiles between very different Windows versions... things will break.
ECHO    *See notes for more detail.
ECHO ################################################################################################
ECHO.

:sourceScan
::CLS
ECHO Potential source drives:
ECHO #####
::ECHO #   #
FOR %%i IN (A B D E F G H I J K L M N O P Q R S T U V W) DO IF EXIST %%i:\Users echo # %%i #
::ECHO #   #
ECHO #####
ECHO.

::Prompt for source drive
SET /P sourceDrive=Enter the drive letter to copy users from: 

SET temp=%sourceDrive:~1,1%
IF NOT "%temp%"==":" SET sourceDrive=%sourceDrive%:

IF NOT EXIST %sourceDrive%\Users ECHO ERROR! No user profiles detected in this drive. Please try again. & pause & GOTO:sourceScan
IF NOT EXIST %sourceDrive%\Windows\System32\config\SOFTWARE ECHO SORRY! No registry hive on this drive. Please restore profiles another way. & pause & EXIT 0
SET sourceUsers=%sourceDrive%\Users


::Display users and prompts
CLS
ECHO.
ECHO Source: %sourceUsers%
ECHO Target: %targetUsers%
ECHO.
ECHO Source profiles:
ECHO.

::DIR %sourceUsers% /O:N /B /D /W
FOR /D %%X in ("%sourceUsers%\*") do call:precheckDuplicate %%X
ECHO.


IF %_existingProfileWarning% GTR 0 (
	ECHO Warning! Some profiles already exist at target. What to do with them?
	set _existingProfileMode=
)
:selectDuplicateMode
IF NOT DEFINED _existingProfileMode set /p _existingProfileMode=Options: (s)kip or (a)rchive copy as username.old: 
IF NOT DEFINED _existingProfileMode GOTO:selectDuplicateMode
IF NOT %_existingProfileMode%==s (
	IF NOT %_existingProfileMode%==a	GOTO:selectDuplicateMode
)


:selectMode
ECHO.
set /p importMode=Import (o)ne or (a)ll profiles? 
IF NOT DEFINED importMode GOTO:selectMode
IF NOT %importMode%==o (
	IF NOT %importMode%==a	GOTO:selectMode
)


::begin logging and work
ECHO BEGINNING RUN: %date% %time% >> %LogFile%
ECHO SOURCE: %sourceUsers% >> %LogFile%
ECHO TARGET: %targetUsers% >> %LogFile%


::PREP WORK::

::Check for and attempt to unload TempHiveLoad. If it is still there after the attempt, give up and exit.
reg query HKLM\TempHiveLoad > nul 2>&1
if %ERRORLEVEL% EQU 0 reg unload HKLM\TempHiveLoad
reg query HKLM\TempHiveLoad > nul 2>&1
if %ERRORLEVEL% EQU 0 ECHO. & ECHO ERROR! Could not unload TempHiveLoad! Quitting... & timeout 9 & GOTO:END

::Load source Registry Hive
reg load HKLM\TempHiveLoad  %sourceDrive%\Windows\System32\config\SOFTWARE

::restore All
if %importMode%==a call:importAll

::restore One
if %importMode%==o call:importOne




:END
::CLEANUP::
reg unload HKLM\TempHiveLoad

ECHO RUN COMPLETED %date% %time% >> %LogFile%
ECHO. >> %LogFile%

ECHO.
pause

color & endlocal
EXIT 0

:precheckDuplicate
SET userPath=%1
For %%f in (%userPath%) do SET user=%%~nxf
IF "%user%"=="Public" endlocal & GOTO:EOF
set _display=%user%
IF EXIST %targetUsers%\%_display%  (set _display=%user% 		-duplicate- & set _existingProfileWarning=1)
ECHO %_display%
GOTO:EOF

:importAll
::Loop
FOR /D %%X in ("%sourceUsers%\*") do call:importUserProfile %%X
GOTO:EOF

:importOne
:selectSource
ECHO.
ECHO Type the name to import, (ie: userxyz)
set /p sourceProfile=
IF NOT EXIST %sourceUsers%\%sourceProfile% ECHO Not found, please try again. & goto:selectSource
CLS
ECHO Using: %sourceUsers%\%sourceProfile%
ECHO.
set /p pressEnter=Press Enter to begin the import... 
color 0e
call:importUserProfile %sourceUsers%\%sourceProfile%
GOTO:EOF



::profileImport:
::	if profile matches a name on the exclude list [public, administrator, etc], skip.
::	if profile exists on targetDrive, do (skip or archive), complete loop.
::	else,
::	robocopy over the profile (filter out temp files and other unwanted)
::	get registry values from source hive and import them
::GOTO:END
:importUserProfile
ECHO.
For %%f in (%1) do SET user=%%~nxf
ECHO LOG USER: %user% TIME: %time% >> %LogFile%
::precheck exclude list
IF "%user%"=="Public" ECHO User skipped. & ECHO User skipped. >> %LogFile% & GOTO:EOF
IF "%user%"=="administrator" ECHO User skipped. & ECHO User skipped. >> %LogFile% & GOTO:EOF
::precheck existing profile
IF EXIST "%targetUsers%\%user%" (
   IF %_existingProfileMode%==s ECHO User already exists. & ECHO User already exists, skipping. >> %LogFile% & GOTO:EOF
   IF %_existingProfileMode%==a ECHO User exists, archiving. & call:archiveImport %1 %user% & GOTO:EOF
)
::Copy user files
ECHO Copying %user%...
ECHO ROBOCOPY LOG: >> %LogFile%
::/E copy subfolders, including empty. /ZB Use restartable/backup mode. /DCOPY:T Copy directory timestamps. /R:0 Zero retries. /V Verbose output log. /NP Dont show % copied. /XJ Exclude Junctions. /XD eXclude Directories matching given names/paths.
ROBOCOPY "%1" "%targetUsers%\%user%" /E /ZB /COPYALL /DCOPY:T /R:0 /V /NP /XJ /LOG+:"%LogFile%" /XD NetHood "Application Data" cache
ECHO END ROBOCOPY LOG. >> %LogFile%
ECHO Importing Registry data...
::Search for user profile key. Note that we assume that the profiles were in c:\users.
for /F "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\TempHiveLoad\Microsoft\Windows NT\CurrentVersion\ProfileList" /f "%targetUsers%\%user%" /d /s /e ^| FIND /I "HKEY" ') do set "userRegKey=%%a"
echo %userRegKey%
set regFile=%targetUsers%\%user%.reg
reg export "%userRegKey%" %regFile%
::Replace the string TempHiveLoad with SOFTWARE in the reg file.
PowerShell.exe -Command "(Get-Content %regFile%).replace(\"TempHiveLoad\", \"SOFTWARE\") | Out-File %regFile%"
::import reg file and delete.
reg import %regFile%
del /f /q %regFile%
GOTO:EOF


:archiveImport
:setRandom
set _somevalue=%random%
if exist "%targetUsers%\%2.old%_somevalue%" goto:setRandom
if not exist "%targetUsers%\%2.old%_somevalue%" (
ECHO Archiving %2...
ECHO ROBOCOPY LOG: >> %LogFile%
::/E copy subfolders, including empty. /ZB Use restartable/backup mode. /DCOPY:T Copy directory timestamps. /R:0 Zero retries. /V Verbose output log. /NP Dont show % copied. /XJ Exclude Junctions. /XD eXclude Directories matching given names/paths.
ROBOCOPY "%1" "%targetUsers%\%2.old%_somevalue%" /E /ZB /COPYALL /DCOPY:T /R:0 /V /NP /XJ /LOG+:"%LogFile%" /XD NetHood "Application Data" cache
ECHO END ROBOCOPY LOG. >> %LogFile%
)
GOTO:EOF




