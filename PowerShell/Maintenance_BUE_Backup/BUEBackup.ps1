###################################################################################################################
#Backup the BUE Catalogs folder
#Disc: This script zips the BUE catalog folder, saves the zip to C:\Temp and moves the zip to \\10.121.38.23
#Loc: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe D:\automation\Maintenance_BUE_Backup\BUEBackup.ps1
###################################################################################################################

<#If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
#>
$TARGETDIR = "C:\Temp"
if( -Not (Test-Path -Path $TARGETDIR ) )
{
    New-Item -ItemType directory -Path $TARGETDIR
}

$Date = (Get-Date).AddDays(-0).ToString('MM-dd-yyyy')
Compress-Archive -Path "C:\Program Files\Symantec\Backup Exec\Catalogs" -Compression Optimal -DestinationPath C:\Temp\$Date.Zip
Move-Item C:\Temp\$Date.zip \\10.121.38.23\phosql03