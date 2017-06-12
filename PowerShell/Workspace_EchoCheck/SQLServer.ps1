$MostRecentDiff = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastDifferentialBackupDate 
$JobStatusDiff = "OK"
$FailListDiff = new-object system.collections.arraylist
ForEach ($ForEachCounterDiff in $MostRecentDiff)
{
if((Get-Date).AddDays(-1) -gt $ForEachCounterDiff.LastBackupDate)
{	
$JobStatusDiff = "Failed"
$FailListDiff += $ForEachCounterDiff
}
}
Write-Output "SQL Differential Backup" ("Status:          [" + $JobStatusDiff + "]<br>") ("The following databaes were not backed up:")  $FailListDiff "<br>" > D:\Log\BackupAudit\SQL-rudw-hls001.txt


##the following overwrites the first step, since there are no differential backups happening on echo. 

$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate 
$JobStatus = "OK"
$FailList = new-object system.collections.arraylist
ForEach ($ForEachCounter in $MostRecent)
{
if((Get-Date).AddDays(-7) -gt $ForEachCounter.LastBackupDate)
{	
$JobStatus = "Failed"
$FailList += $ForEachCounter
}
}
if ($JobStatus = "OK")
{
Write-Output ("SQL Full Backup<br>") ("Status:          [" + $JobStatus + "]<br>") > D:\Log\BackupAudit\SQL-rudw-hls001.txt
}
else
{
Write-Output ("SQL Full Backup<br>") ("Status:          [" + $JobStatus + "]<br>") ("The following databaes were not backed up:")  $FailList "<br>" > D:\Log\BackupAudit\SQL-Rudw-hls001.txt
}