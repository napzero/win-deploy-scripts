cd $PSScriptRoot

$zipFile = ".\processing-3.5.3-windows64.zip"
$extractedName = "processing-3.5.3"
$desiredName = "processing-3"


#if 7-zip is installed, use it, otherwise use Expand-Archive.
$zipexe = "C:\Program Files\7-Zip\7z.exe"
if (Test-Path $zipexe ) { cmd /c $zipexe x $zipFile -y }
else {Expand-Archive -Path $zipFile -DestinationPath ".\" -Force}


if (Test-Path .\$extractedName ) {
robocopy /MOVE /E .\$extractedName "C:\Program Files\$desiredName"
#Move-Item -Path .\$extractedName -Destination $desiredName -Force
#Move-Item -Path .\$desiredName -Destination "C:\Program Files\" -Force
}
else {Write-Warning "Unable to extract archive!"
    Write-Error $_
	timeout 9
	}


#Install the shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Processing.lnk")
$Shortcut.TargetPath = "C:\Program Files\processing-3\processing.exe"
$Shortcut.Save()


#read-host -Prompt "Press Enter to continue"
