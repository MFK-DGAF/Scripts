param([string]$BackupJob="BackupAll.Subplan_1", [int]$FullDistance = -4,[string]$LogDir = "D:\Logs\BackupAudit\")

#Import the SQL functions
import-module sqlps -ErrorAction silentlycontinue
Add-PSSnapin SqlServerCmdletSnapin100 -ErrorAction silentlycontinue
Add-PSSnapin SqlServerProviderSnapin100 -ErrorAction silentlycontinue

#################################
#output/shared variables
#################################
$ServerName = $env:COMPUTERNAME
$FileName = write-output ("SQL-" + $ServerName + ".txt")
$OutFile = $LogDir + $FileName

############################
#Backup Status Variables
###########################
$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate 
$JobStatusFull = "OK"
$FailList = new-object system.collections.arraylist

############################
#Log Status Variables
############################
$FailListLog = new-object system.collections.arraylist
$JobStatusLog = "OK"
$today = get-date
$ServerName = $env:COMPUTERNAME
$SQL_LOG_QUERY =@"
USE msdb ;  
GO  
EXEC dbo.sp_help_jobhistory   
    @job_name = N`$(JobName) ;  
GO  
"@
$Job_Param = "JobName='" + $BackupJob + "'"
$Job_Log = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $SQL_LOG_QUERY -Variable $Job_Param

##################################################################################
##Test if date of the last full backups are within the limit set by $FullDistance
##################################################################################
ForEach ($ForEachCounter in $MostRecent)
{
    if((Get-Date).AddDays($FullDistance) -gt $ForEachCounter.LastBackupDate)
    {	
        $JobStatusFull = "Failed"
        $FailList += $ForEachCounter
    }
}

############################################################
##Test if there were any backups being tested
#This will be null if the sql sections do not load
###########################################################
if ($mostRecent.Count -eq $null)
{
    $failMessage = "There was a problem running the script<br>"
}
else 
{
    $failMessage = write-output ("The following databases were not backed up:<br>")  $FailList "<br>"
}

######################################################################
##Test if the last Seven days are without error in the backup logs
######################################################################
ForEach ($JobLogItem in $Job_Log)
{
    $JobDate = [datetime]::ParseExact($JobLogItem.run_date, "yyyyMMdd", $null)
    if ($JobDate -gt $today.AddDays(-7))
    {
        if ($JobLogItem.run_status -eq 0) 
        {
               $JobStatusLog = "FAILED"
               $FailListLog += $JobDate
               $FailListLog += "<br>"
        }
    }
}



#############################################################
##Generates report based on results 
##first if combines report output into one line if both pass
#############################################################

if (($JobStatusFull -match "OK") -and ($JobStatusLog -match "OK"))
{
Write-Output ("SQL Backup<br>") ("Status:           [" + $JobStatusFull + "]<br>") > $OutFile
}
else
{
	if ($JobStatusFull -match "OK")
	{
	Write-Output ("SQL Full Backup<br>") ("Status:           [" + $JobStatusFull + "]<br>") > $OutFile
	}
	else
	{
	Write-Output ("SQL Full Backup<br>") ("Status:           [" + $JobStatusFull + "]<br>") $failmessage > $OutFile
	}

	if ($JobStatusLog -match "OK")
	{
	Write-Output ("SQL Backup Log<br>") ("Status:           [" + $JobStatusLog + "]<br>") >> $OutFile
	}
	else
	{
	Write-Output ("SQL Backup Log<br>") ("Status:           [" + $JobStatusLog + "]<br>") ("There was an error reported in the SQL backups on the following dates<br>") $FailListLog >> $OutFile
	}
}