$OSthreshhold = 10
$DATAthreshhold = 100
$LOGThreshhold = 100
$BAKThreshhold = 500
$OSdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" |
Select-Object Size,FreeSpace
$DATAdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='E:'" |
Select-Object Size,FreeSpace
$LOGdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='F:'" |
Select-Object Size,FreeSpace
$BAKdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='G:'" |
Select-Object Size,FreeSpace
$OSSpace = [math]::truncate($OSdisk.FreeSpace/1048576/1024)
$DATASpace = [math]::truncate($OSdisk.FreeSpace/1048576/1024)
$LOGSpace = [math]::truncate($LOGdisk.FreeSpace/1048576/1024)
$BAKSpace = [math]::truncate($BAKdisk.FreeSpace/1048576/1024)
$Status = "Success"
If ($OSSpace -lt $OSThreshhold){
	$Status = "Fail"}
If ($DATASpace -lt $DATAThreshhold){
	$Status = "Fail"}	
If ($LOGSpace -lt $LOGThreshhold){
	$Status = "Fail"}
If ($BAKSpace -lt $BAKThreshhold){
	$Status = "Fail"}

If ($Status -eq "Fail")
{
$ReportMessage = write-output "Hard Disk Space" "Status:          [FAIL] " ("OS partition has " + $OSSpace + "GB free") ("DATA partition has " + $DATASpace + "GB free") ("LOG partition has " + $LOGSpace + "GB free") ("BAK partition has " + $BAKSpace + "GB free")
}
else
{
$ReportMessage = write-output "Hard Disk Space" "Status:          [OK] "}

Write-Output $ReportMessage > F:\BackupAudit\DiskSpace-PHOSQL03.txt