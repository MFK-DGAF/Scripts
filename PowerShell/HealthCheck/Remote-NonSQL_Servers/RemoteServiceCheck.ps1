$ServerList = Get-Content E:\automation\HealthCheck\Remote\NOSQLServerlist.txt
foreach ($Server in $Serverlist)
{
	$ServiceStatus = "[OK]"
	$RebootStatus = "[OK]"
	$ServiceListString = write-output ("E:\automation\HealthCheck\Remote\" + $Server + "-Service.txt")
	$ServiceCheckList = Get-Content $ServiceListString
	$ServiceListArray = "one", "two", "three"
	$ServiceListArray = ""
	foreach ($ListElement in $ServiceCheckList)
	{
		$ServiceListArray += $ListElement
	}	
	$ServiceList = get-service -computername $Server -include $ServiceListArray
	$failcount = 0
	foreach ($Service in $ServiceList)
	{
		if ($Service.Status -ne "Running")
    		{
        		$failcount = $failcount + 1
        		if ($failcount -eq 1) 
        		{
            			$faillist = $service.Name
        		}
        		else
        		{
        		$faillist = write-output ($faillist + ", " + $Service.Name)
			}
        	}
    	}
	if ($failcount -eq 0)
		{$ReportMessage = write-output ("Host Services") ("Status:              [OK]")}
	else
		{$ReportMessage = write-output ("Host Services") ("Status:              [FAIL]") ("The following services are not running: " + $faillist)}

	$ServerFile = write-output ("F:\BackupAudit\Remote\Service-" + $Server + ".txt")
	$ReportMessage | Set-Content -Path $ServerFile

	$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer1)
	$RegKey= $Reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
	
	if ($RegKey -eq $null)
		{
		$ReportMessage2 = write-output ("Pending Reboot") ("Status:              [OK]")
		}
	else
		{
		$ReportMessage2 = write-output ("Pending Reboot") ("Status:              [REBOOT REQUIRED]")
		}
	$ReportMessage2 | Add-Content -Path $ServerFile
}