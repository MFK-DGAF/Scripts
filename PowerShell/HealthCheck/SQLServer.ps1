$MostRecentDiff = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastDifferentialBackupDate 
$JobStatusDiff = "OK"
$FailListDiff = new-object system.collections.arraylist
ForEach ($ForEachCounterDiff in $MostRecentDiff)
{
if((Get-Date).AddDays(-4) -gt $ForEachCounterDiff.LastBackupDate)
{	
$JobStatusDiff = "Failed"
$FailListDiff += $ForEachCounter
}
}
Write-Output "SQL Differential Backup" ("Status:          [" + $JobStatusDiff + "]") ("The following databaes were not backed up:")  $FailListDiff > F:\BackupAudit\SQL-PHOSQL03.txt



$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate 
$JobStatus = "OK"
$FailList = new-object system.collections.arraylist
ForEach ($ForEachCounter in $MostRecent)
{
if((Get-Date).AddDays(-8) -gt $ForEachCounter.LastBackupDate)
{	
$JobStatus = "Failed"
$FailList += $ForEachCounter
}
}
if ($JobStatus = "OK")
{
Write-Output ("SQL Full Backup") ("Status:          [" + $JobStatus + "]") >> F:\BackupAudit\SQL-PHOSQL03.txt
}
else
{
Write-Output ("SQL Full Backup") ("Status:          [" + $JobStatus + "]") ("The following databaes were not backed up:")  $FailList >> F:\BackupAudit\SQL-PHOSQL03.txt
}