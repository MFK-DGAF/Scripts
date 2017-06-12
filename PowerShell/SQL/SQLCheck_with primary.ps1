import-module sqlps
$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate | Where {$_.LastBackupDate -gt (get-date 2014-02-01)}
$JobStatus = "[OK]"
$FailList = new-object system.collections.arraylist
$Counttest = $FailList.Count
$Failed=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@
$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@
$Secondary=@"
[<font color="red"><b>Secondary</b></font>]<br>
"@
$Primary=@"
[<font color="#66FF33"><b>Primary</b></font>]<br>
"@


$ServerName = $env:COMPUTERNAME
[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.Smo”) |Out-Null
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server("$ServerName")
$DBList = $SqlServer.AvailabilityGroups[“SharePoint”].AvailabilityReplicas | Select-Object Name, Role
$primarycount = 0
$secondarycount = 0
foreach ($DBServer in $DBList)
{
		if ($DBServer.Role -match "Primary")
		{
				$primary = $DBServer.Name
				$primarycount++
		}
		if ($DBServer.Role -match "Secondary")
		{
				$secondary = $DBServer.Name
				$secondarycount++
		}
		
}
if (($primarycount -ne 1) -or ($secondarycount -ne 1))
{
    $PrimaryStatus = "Failed"
}
else 
{
    if ($Primary -match $ServerName)
    {
    $PrimaryStatus = "Primary"
    }
    if ($Secondary -match $ServerName)
    { 
    $PrimaryStatus = "Secondary"
    }
}

#################################
#SQL check for age of backups.
#################################

ForEach ($ForEachCounter in $MostRecent){if((Get-Date).AddDays(-7) -gt $ForEachCounter.LastBackupDate){$FailList += $ForEachCounter}}
if ($FailList.Count -gt 0){$JobStatus = "[FAILED]"}

###############################
#Output SQL Primary status to file
#################################

if ($PrimaryStatus -match "Primary")
{
    $PjobOut = $Primary
}
if ($PrimaryStatus -match "Secondary")
{
    $PjobOut = $Secondary
}
if ($PrimaryStatus -match "Failed")
{
    $PjobOut = $Failed
}


#################################
#Outputs Primary
################################

{Write-Output ("SQL Primrary <br>") ("Status:              " + $PjobOut) > F:\HealthCheck\SQL-MarioSPDB.txt} 


###############################
#Output SQL Backup status to file
#################################
if ($JobStatus -eq "[OK]"){Write-Output ("SQL Backup<br>") ("Status:              " + $OK) >> F:\HealthCheck\SQL-MarioSPDB.txt} `
else {Write-Output ("SQL Backup<br>")("Status:              " + $Failed) ("The following " + $FailList.Count + " databases have not been backed up in the past week:")  $FailList (" ") >> f:\HealthCheck\SQL-MarioSPDB.txt}

