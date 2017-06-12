import-module sqlps

###############################################
# Base disk check portion
###############################################
#Set the threshholds for the different partitions
$OSthreshhold = 5
$DATAthreshhold = 200
$LOGThreshhold = 50

#create the disk objects to check the free space
$OSdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" |
Select-Object Size,FreeSpace
$DATAdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='E:'" |
Select-Object Size,FreeSpace
$LOGdisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'" |
Select-Object Size,FreeSpace

#Calculate the free space
$OSSpace = [math]::truncate($OSdisk.FreeSpace/1048576/1024)
$DATASpace = [math]::truncate($DATAdisk.FreeSpace/1048576/1024)
$LOGSpace = [math]::truncate($LOGdisk.FreeSpace/1048576/1024)

#compare the existing free space to the threshholds
$Status = "Success"
If ($OSSpace -lt $OSThreshhold){
	$OSStatus = "Fail"}
If ($DATASpace -lt $DATAThreshhold){
	$DataStatus = "Fail"}	
If ($LOGSpace -lt $LOGThreshhold){
	$LogStatus = "Fail"}

###############################################
# Free space to backup comparison
###############################################
$BackupStatus = "OK"
$ParentBackDir = "E:\Backup"
$BackDirs = Get-ChildItem $ParentBackDir | ?{ $_.PSIsContainer } | Select-Object FullName
$BackupSize = 0
foreach ($BackupDirectory in $BackDirs)
{
    $Backups = get-childitem $BackupDirectory.Fullname
    $biggest = 0
    foreach ($Backup in $Backups)
    {
        if ($Backup.Length -gt $biggest)
        {
            $biggest = $Backup.Length
        }
    }
    $BackupSize += $biggest/1024/1024/1024
}

IF ($DATASpace -lt $BackupSize)
{
    $BackupStatus = "Fail"
}

##############################################
#SQL Log Test
##############################################

$BackupJob = "BackupEcho.Subplan_1"
$JobStatusLog = "OK"
$FailListLog = new-object system.collections.arraylist
#Declare query to get execution history
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
                                 
##Test if the last Seven days are without error in the backup logs
ForEach ($JobLogItem in $Job_Log)
{
    $JobDate = [datetime]::ParseExact($JobLogItem.run_date, "yyyyMMdd", $null)
    if ($JobDate -gt $today.AddDays(-7))
    {
        if ($JobLogItem.run_status -eq 0) 
        {
               $JobStatusLog = "FAIL"
               $FailListLog += $JobDate
        }
    }
}

######################################################
# Sort Fails To Generate Email
######################################################



If (($JobStatusLog -eq "OK") -and ($BackupStatus -eq "OK") -and ($OSStatus -eq "OK") -and ($LogStatus -eq "OK") -and ($DataStatus -eq "OK")
{
    $messageSubject = "Echo Server Health Nominal"
    $body = "There is sufficient space and no problems with the SQL backup logs"
}
else 
{
    $messageSubject = "There is a problem with the Echo server"
    $body = write-output "The following problems were detected" ""
    if ($JobStatusLog -ne "OK")
    {
    $body+= write-output "There were errors detected in the sql backup log" $FailListLog ""
    }
    if ($BackupStatus -ne "OK")
    {
    $body+= write-output "There is insufficient freespace on E:\ to run a weekly backup." ("A full backup will require " + $BackupSize + " GB.") ("There is only " + $DATASpace + " GB free") ""
    }
    if ($OSStatus-ne "OK")
    {
    $body+= write-output "The OS Partition is low on space." ("There is only " + $OSSpace + " GB free") ""
    }
    if ($LogStatus -ne "OK")
    {
    $body+= write-output "The Log Partition is low on space." ("There is only " + $LogSpace + " GB free") ""
    }
    if ($DataStatus -ne "OK")
    {
    $body+= write-output "The Data Partition is low on space." ("There is only " + $DataSpace + " GB free") ""
    }
}

#######################################################
# Send the emails
#######################################################

$smtpServer = "PHOSQL-STAGING"
$smtpFrom = "HealthCheck@Rush-Health.com"

$smtpTo = "Torsten_Spooner@rush.edu"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver" 