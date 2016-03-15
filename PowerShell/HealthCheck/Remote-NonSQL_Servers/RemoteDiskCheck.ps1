$ServerList = Get-Content E:\automation\HealthCheck\Remote\NOSQLServerlist.txt

foreach ($Server in $Serverlist)
{
	$ServerStatus = "[OK]"
	$ServerDrives = Get-WmiObject Win32_LogicalDisk -ComputerName $Server
	$ServerMessage = ""
	$ServerDriveMessage = ""
	$ServerFile = write-output ("F:\BackupAudit\Remote\Disk-" + $Server + ".txt")
	###write-output $Server
	foreach ($Drive in $ServerDrives)
	{	
		
		if ($Drive.DriveType -eq 3)
		{
			####Sets the Status to Warn (<35% free) or FAIL (<20% free)
			####Adds the full drives to report
			####
			$DrivePercentFree = ($Drive.Freespace/$Drive.Size)
			if ($DrivePercentFree -lt .35)
			{
				if ($ServerStatus -eq "[OK]")
				{
					$ServerStatus = "[Warning]"
				}
				$DriveFreeSpace = [math]::truncate($Drive.FreeSpace/1048576/1024)
				$DriveMessage = write-output ($Drive.DeviceID + " only has " + $DriveFreeSpace + "GB free`t") 
				$ServerDriveMessage = write-output ($ServerDriveMessage) ($DriveMessage)
				if ($DrivePercentFree -lt .2)
				{
					$ServerStatus = "[FAIL]"
				}
			}
		}
	}
	if ($ServerStatus -eq "[OK]"){
	$ServerMessage = write-output ("Disk Space Check") ("Status:              " + $ServerStatus)}
	if ($ServerStatus -ne "[OK]"){
	$ServerMessage = write-output ("Disk Space Check") ("Status:          " + $ServerStatus) $ServerDriveMessage}
	$ServerMessage | Set-Content -Path $ServerFile
}