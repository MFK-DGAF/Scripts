$OSthreshhold = 5
$DATAthreshhold = 200
$LOGThreshhold = 50

$OSdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" |
Select-Object Size,FreeSpace
$DATAdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='E:'" |
Select-Object Size,FreeSpace
$LOGdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'" |
Select-Object Size,FreeSpace

$OSSpace = [math]::truncate($OSdisk.FreeSpace/1048576/1024)
$DATASpace = [math]::truncate($DATAdisk.FreeSpace/1048576/1024)
$LOGSpace = [math]::truncate($LOGdisk.FreeSpace/1048576/1024)

$Status = "Success"
If ($OSSpace -lt $OSThreshhold){
	$Status = "Fail"}
If ($DATASpace -lt $DATAThreshhold){
	$Status = "Fail"}	
If ($LOGSpace -lt $LOGThreshhold){
	$Status = "Fail"}

If ($Status -eq "Fail")
{
$ReportMessage = write-output "Hard Disk Space<br>" "Status:          [FAILED]<br> " ("OS partition has " + $OSSpace + "GB free<br>") ("DATA partition has " + $DATASpace + "GB free<br>") ("LOG partition has " + $LOGSpace + "GB free<br>")
}
else
{
$ReportMessage = write-output "Hard Disk Space<br>" "Status:          [OK]<br> "}

Write-Output $ReportMessage > D:\Log\BackupAudit\DiskSpace-rudw-hls001.txt