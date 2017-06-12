import-module sqlps

$Failed=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@


$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate | Where {$_.LastBackupDate -gt (get-date 2014-01-01)}
$JobStatus = "[OK]"
$FailList = new-object system.collections.arraylist
ForEach ($ForEachCounter in $MostRecent){
if((Get-Date).AddDays(-7) -gt $ForEachCounter.LastBackupDate){$FailList += $ForEachCounter}}
if ($FailList.Count -gt 0){$JobStatus = "[FAILED]"}

if ($JobStatus -eq "[OK]"){
Write-Output ("SQL Backup<br>")("Status:              " + $OK) > D:\HealthCheck\SQL-Hermes.txt}
else {
Write-Output ("SQL Backup<br>")("Status:              " + $Failed) ("The following databaes have not had a full backup in the past week:<br>")  $FailList "<br>" > D:\HealthCheck\SQL-Hermes.txt}

