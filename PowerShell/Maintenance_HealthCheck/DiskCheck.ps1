param(
[string]$ParentBackDir = "F:\Backups", 
[string]$outputDir = "E:\HealthCheckLogs", 
$WarnThreshold = .20, 
$ErrrorThreshold = .10 
)

##########################################################################################
# Disk Check 
# version 1.0
# 01/16/2017
# Changes: 
# Added Parameters for Parent Backup Dir and Output dir
# Added coloring, bold, and italics to script
# Changed output type to HTML
# Added disk cleanup when it's estimated a backup will fail
##########################################################################################

$ServerDrives = Get-WmiObject Win32_LogicalDisk
$ServerStatus = "OK"
$ServerMessage = ""
$ServerDriveMessage = ""
$ServerFile = write-output ($outputDir + "\DiskCheck-" + $env:COMPUTERNAME + ".html")

##Declare the color variables
$red=@"
<font color="red"><b>
"@

$end=@"
</b></font>
"@

$yellow=@"
<font color="#FFCC33"><b>
"@

$Warn=@"
[<font color="#FFCC33"><b>Warning</b></font>]<br>
"@

$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@


###############################################
# Free space to backup size comparison
###############################################
$BackupStatus = "OK"
$BK_DL = $ParentBackDir.Substring(0,2)
$filter = write-output ("DeviceID='" + $BK_DL + "'")
$BackupsDisk = Get-WmiObject Win32_LogicalDisk -Filter $filter | Select-Object Size,FreeSpace
$BackupsSpace = [math]::truncate($BackupsDisk.FreeSpace/1048576/1024)

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

###################################################
# Removes the oldest bak file from each directory 
# until there is enough room for a full backup
# ONLY RUNS IF THERE IS NOT ENOUGH ROOM FOR FULL BK
###################################################
$backupcleanup_ran = 0
while ($BackupSize -gt $BackupsSpace)
{
    $backupcleanup_ran = 1
    foreach ($BackupDirectory in $BackDirs)
    {
        $Backups = get-childitem $BackupDirectory.Fullname -filter "*.bak"
        $oldest = get-date
        foreach ($Backup in $Backups)
        {
            if ($Backup.LastWriteTime -lt $oldest)
            {
                $oldest = $Backup.LastWriteTime
                $oldestName = $Backup.FullName
            }
        }
        Remove-Item $oldestName
    }
    $BackupsDisk = Get-WmiObject Win32_LogicalDisk -Filter $filter | Select-Object Size,FreeSpace
    $BackupsSpace = [math]::truncate($BackupsDisk.FreeSpace/1048576/1024)
}

###########################################################
# Checks the amount of freespace for each drive compared to 
# the percentages allowed
###########################################################


foreach ($Drive in $ServerDrives)
{	
		
	if ($Drive.DriveType -eq 3)
	{
	    ####Sets the Status to Warn (<35% free) or FAIL (<20% free)
	    ####Adds the full drives to report
	    
        $DrivePercentFree = ($Drive.Freespace/$Drive.Size)
	    if ($DrivePercentFree -lt $WarnThreshold)
	    {
		    if ($ServerStatus -eq "OK")
		    {
		    	$ServerStatus = "Warning"
		    }
		    $DriveFreeSpace = [math]::truncate($Drive.FreeSpace/1048576/1024)
	        $DriveMessage = write-output ("<i>" + $Drive.DeviceID + " only has " + $red + $DriveFreeSpace + $end + "GB free</i><br>") 
		    $ServerDriveMessage = write-output ($ServerDriveMessage) ($DriveMessage)
		    if ($DrivePercentFree -lt $ErrrorThreshold)
		    {
		    	$ServerStatus = "Failed"
		    }
	    }
    }
}


######################################
# logic for server backup status
# and generation of message/file
######################################
if ($ServerStatus -eq "Warning") {$ServerStatusText = $Warn}
if ($ServerStatus -eq "Failed") {$ServerStatusText = $Fail}

if (($ServerStatus -eq "OK") -and ($backupcleanup_ran -eq 0)) {$ServerStatusText = $OK}
if (($ServerStatus -eq "OK") -and ($backupcleanup_ran -eq 1)) 
{
    $ServerStatusText = "$fail"
    $ServerDriveMessage = write-output ($ServerDriveMessage) ("<i>The Cleanup job was run on the server. It did not have sufficient space to run a full backup.</i> <br>")
}

if ($ServerStatus -eq "OK"){ $ServerMessage = write-output ("<b>Disk Space Check</b><br>") ("Status:              " + $ServerStatusText)}
if ($ServerStatus -ne "OK"){ $ServerMessage = write-output ("<b>Disk Space Check</b><br>") ("Status:          " + $ServerStatusText) $ServerDriveMessage}

$ServerMessage | Set-Content -Path $ServerFile