@echo off
setlocal
cd /d %0\.. & color 0e & ECHO Installing 7-ZIP & SET INSTALLPARAMS=/qn /norestart & SET VERSION=7z1900

if defined ProgramFiles(x86) (set "INSTALLFILE=%VERSION%-x64.msi") ELSE (set "INSTALLFILE=%VERSION%.msi")
set pathtoexe="%ProgramFiles%\7-Zip\7zFM.exe"

::Uninstall old versions
MsiExec.exe /X{23170F69-40C1-2702-1604-000001000000} /qn /norestart
MsiExec.exe /X{23170F69-40C1-2702-1804-000001000000} /qn /norestart
MsiExec.exe /X{23170F69-40C1-2702-1805-000001000000} /qn /norestart

msiexec /i "%INSTALLFILE%" %INSTALLPARAMS%

::fix 7z file association
:fixFileAssociation
if NOT exist %pathtoexe% ECHO ERROR, 7-zip exe not found. & call:tryToFixBrokenInstall
set ftypename=7z_Archive
set extension=.7z
set pathtoicon=""
if %pathtoicon%=="" set pathtoicon=%pathtoexe%,0
REG ADD HKEY_CLASSES_ROOT\%extension%\ /t REG_SZ /d %ftypename% /f
REG ADD HKLM\SOFTWARE\Classes\%ftypename%\DefaultIcon\ /t REG_SZ /d %pathtoicon% /f
ftype %ftypename%=%pathtoexe% "%%1" %%*
assoc %extension%=%ftypename%
:EndOf7zFileAssociationFix

endlocal
color & EXIT 0


:tryToFixBrokenInstall
ECHO One moment please, attempting fix...
wmic product where "Name like '%%7-Zip%%'" call uninstall
msiexec /i "%INSTALLFILE%" %INSTALLPARAMS%
if NOT exist %pathtoexe% ECHO ERROR, 7-ZIP INSTALL WAS NOT SUCCESSFUL. & timeout 9 & GOTO:EndOf7zFileAssociationFix
GOTO:EOF
