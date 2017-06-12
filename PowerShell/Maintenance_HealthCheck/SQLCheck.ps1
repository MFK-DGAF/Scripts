param(
[string]$FullJob="MAINTENANCE_BackupWeekly.Backup and Cleanup", 
[string]$IncJob="MAINTENANCE_BackupDaily.Incremental Backups",
[string]$outputDir="",
[int]$FullDistance = -7,
[int]$IncDistance = -4,
[switch]$differential
)

##########################################################################################
# SQL Check 
# version 1.0
# 01/16/2017
# Changes: 
# Added Parameters for Job Names, output Dir, and job distance
# Added coloring, bold, and italics to script
# Changed output type to HTML
# Created flag so Full only backup schemes don't need a separate script
##########################################################################################

# import SQL module
##########################################################################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}


##Declare the color variables
############################################################################################
$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@

#Location Variables
$filename = write-output ("\SQL-" + $env:ComputerName + ".html")

$outputFile = $outputdir + $filename
$faillistlog = @()

#Declare query to get execution history
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


###################################
# Checks the age/logs of the differential backups
###################################
$JobStatusDiff = "OK"
if ($differential)
{
    #variables for Differential log check
    $Job_Param = "JobName='" + $IncJob + "'"
    $Job_LogInc = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $SQL_LOG_QUERY -Variable $Job_Param

    #variables for Differential age check
    $MostRecentDiff = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastDifferentialBackupDate, Status | Where {$_.Status -ne "Offline"}
    $FailListDiff = new-object system.collections.arraylist
    
    #checks age of Differential backups
    ForEach ($ForEachCounterDiff in $MostRecentDiff)
    {
	    if((Get-Date).AddDays($incDistance) -gt $ForEachCounterDiff.LastDifferentialBackupDate)
	    {	
	    $JobStatusDiff = "FAILED"
	    $FailListDiff += write-output ("<i>" + $ForEachCounterDiff.Name + "         " + $ForEachCounterDiff.LastBackupDate + "</i><br>")
	    }
    }
    
    #checks past week for failures in the differential job log
    ForEach ($JobLogItem in $Job_LogInc)
    {
        $JobDate = [datetime]::ParseExact($JobLogItem.run_date, "yyyyMMdd", $null)
        if ($JobDate -gt $today.AddDays(-7))
        {
            if ($JobLogItem.run_status -eq 0) 
            {
               $JobStatusLog = "FAILED"
               $FailListLog += write-output ("<i>" + $JobDate.ToString("D") + "</i><br>")
            }
        }
    }
}

#####################################
# Checks the age of the full backups
#####################################

$Job_Param = "JobName='" + $FullJob + "'"
$Job_LogFull = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $SQL_LOG_QUERY -Variable $Job_Param


$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, LastBackupDate, Status 
$JobStatus = "OK"
$FailList = new-object system.collections.arraylist
$RestoringList = new-object system.collections.arraylist

ForEach ($ForEachCounter in $MostRecent)
{
	if((Get-Date).AddDays($FullDistance) -gt $ForEachCounter.LastBackupDate)
	{	
		$JobStatus = "FAILED"
		$FailList += write-output ("<i>" + $ForEachCounter.Name + "         " + $ForEachCounter.LastBackupDate + "</i><br>")
	}
}

########################################################
# Checks if any of the databases are stuck restoring
########################################################
$JobStatusRestoring = "OK"
ForEach ($ForEachCounter in $MostRecent)
{
    if ($ForEachCounter.Status -eq "Restoring")
    {
        $JobStatusRestoring = "FAILED"
        $RestoringList += write-output ("<i>" + $ForEachCounter.Name + "</i><br>")
    }
}



#################################################################
#Test if the last Seven days are without error in the backup logs
#################################################################
ForEach ($JobLogItem in $Job_LogFull)
{
    $JobDate = [datetime]::ParseExact($JobLogItem.run_date, "yyyyMMdd", $null)
    if ($JobDate -gt $today.AddDays(-7))
    {
        if ($JobLogItem.run_status -eq 0) 
        {
               $JobStatusLog = "FAILED"
               $FailListLog += write-output ("<i>" + $JobDate.ToString("D") + "</i><br>")
        }
    }
}



#################################################################
# Perform error message generation logic and output reports
################################################################

if (($JobStatusDiff -match "OK") -And ($JobStatus -match "OK") -AND ($JobStatusLog -eq "OK") -AND ($JobStatusRestoring -eq "OK" ))
{
    $outputMessage =  Write-Output ("<b>SQL Operations</b><br>") ("Status:          " + $OK) 
}
else
{

    if ($JobStatusLog -eq "FAILED")
    {
        $outputMessage += Write-Output ("<b>SQL Backup Log</b><br>") ("Status:          " + $Fail) ("The jobs failed on the following days:<br>" + $FailListLog)
    }
    if ($JobStatusRestoring -eq "FAILED")
    {
        $outputMessage += Write-Output ("<b>SQL Database Status</b><br>") ("Status:          " + $Fail) ("The following databases were still restoring:<br>" + $RestoringList)
    }
    
    #######################################################
    # Appends output of the full job to the healthcheck file
    #######################################################
    if ($JobStatus -match "OK")
    {
    	$outputMessage += Write-Output ("<b>SQL Full Backup</b><br>") ("Status:          " + $OK)
    }
    else
    {
    	$outputMessage += Write-Output ("<b>SQL Full Backup</b><br>") ("Status:          " + $fail) ("The following databaes were not backed up:<br>")  $FailList 
    }

    if ($differential)
    {
        #######################################################
        # Writes output of the diff job to the healthcheck file
        #######################################################
        If ($JobStatusDiff -match "FAILED")
        {
    	    $outputMessage += Write-Output $LogStatusText "<b>SQL Differential Backup</b><br>" ("Status:          " + $fail) ("The following databaes were not backed up:<br>")  $FailListDiff 
        }
        Else
        {
    	    $outputMessage += Write-Output $LogStatusText "<b>SQL Differential Backup</b><br>" ("Status:          " + $OK)
        }
    }
}

write-output $outputMessage > $outputFile
