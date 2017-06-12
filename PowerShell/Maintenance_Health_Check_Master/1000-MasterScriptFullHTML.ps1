param(
[string]$ServerListLocation = "E:\automation\Maintenance_Health_Check_Master\Serverlist.txt",
[string]$RemoteServerListLocation = "E:\automation\Maintenance_Health_Check_Remote\Lists\NoSQLServerList.txt",
[string]$RemoteDiskFileLoc = "D:\HealthCheckLogs\Remote\",
[string]$RemoteServiceFileLoc = "D:\HealthCheckLogs\Remote\",
[string]$MasterTextFile = "D:\HealthCheckLogs\MasterText.html",
[string]$shareName = "HealthCheckLogs"
)

#define parameters
################################################
# DECLARE VARIABLES
#
################################################
#list of servers
$ServerList = Get-Content $ServerListLocation
# array of servers with servername and the text for the email
$MasterList = new-object system.collections.arraylist

###############################################
# DEFINE REBOOT FUNCTION
#
###############################################

###################################################################
# Reboot Time Arrays And function
###################################################################
$430_file = "E:\Automation\Maintenance_ServerReboots\Reboot_Lists\FourThirty_Reboots.txt"
$4AM_file = "E:\Automation\Maintenance_ServerReboots\Reboot_Lists\FourInTheAM_Reboots.txt"
$5AM_file = "E:\Automation\Maintenance_ServerReboots\Reboot_Lists\FiveInTheAM_Reboots.txt"

#$four_AM_Array = "laurel3", "teller3", "rush-mercury", "hermes". "hardy3", "penn3", "laurel-mart3", "teller-mart3", "pmmc2", "cheech", "ginger", "koopa", "bowser", "Mario", "mario-app", "mario-spdb1", "mario-web", "mario-extdb", "mario-extweb", "wario"
#$four_30_Array = "chong", "maryann", "donkeykong", "luigi", "luigi-app", "lugi-spdb1", "luigi-spweb", "luigi-extdb", "luigi-extweb"
#$five_AM_Array = "Yoshi", "yoshi-app2", "yoshi-db2", "yoshi-web2", "yoshi-extdbweb"
function reboot_test ($servername, $scriptblock)
    {
    $four_AM_Array = "laurel3", "teller3", "rush-mercury", "hermes". "hardy3", "penn3", "laurel-mart3", "teller-mart3", "pmmc2", "cheech", "ginger", "koopa", "bowser", "Mario", "mario-app", "mario-spdb1", "mario-web", "mario-extdb", "mario-extweb", "wario"
    $four_30_Array = "chong", "maryann", "donkeykong", "luigi", "luigi-app", "lugi-spdb1", "luigi-spweb", "luigi-extdb", "luigi-extweb"
	$five_AM_Array = "Yoshi", "yoshi-app2", "yoshi-db2", "yoshi-web2", "yoshi-extdbweb"
    $action = 0
    if ((Get-Date).DayOfWeek -eq "Wednesday")
        {
        if ($scriptblock -like "*REBOOT REQUIRED*")
            {
            if($four_AM_Array -contains $servername)
                {
                $action = 1
                }
            if($four_30_Array -contains $servername)
                {
                $action = 2
                }
			if($five_AM_Array -contains $servername)
                {
                $action = 3
                }	
            }
         }
    return $action
    }

###################################################
# DEFINE COMPRESSION FUNCTION
# Takes in the 3 reports from the different servers
# If all 3 reports have no issues, it will output 
# a compressed version of the text
###################################################

function output_compression ([string]$servername, [string]$ServiceText, [string]$DiskText, [string]$SQLText = "")
{
    $GoodMessage = write-output "<b>All Server Functions</b><br>" "Status:          [OK]<br> "
    $ServerHostnameText = write-output ("<br>-----------------------------<br><b>" + $servername + "</b><br>-----------------------------<br>")
    $ErrorCount = 0
    [string]$outputtext = ""
    if (($SQLText -like "*Failed*") -OR ($SQLText -like "*Not Running*"))   {$ErrorCount++}
    if (($DiskText -like "*Failed*") -OR ($DiskText -like "*Not Running*"))   {$ErrorCount++}
    if (($ServiceText -like "*Failed*") -OR ($ServiceText -like "*Not Running*") -OR ($ServiceText -like "*REBOOT REQUIRED*")) {$ErrorCount++}
    if ($ErrorCount -gt 0)
    {
        $outputText = write-output ($ServerHostnameText + $SQLText + $DiskText + $ServiceText)
    }
    else 
    {
        $outputText = write-output ($ServerHostnameText + $GoodMessage)
    }
    return $outputText
}


###############################################
# DEVICE CHECK
# Checks on the status of the backup devices
# Silent unless one does not respond to ping
###############################################
##Declares the array of backup devices

$DeviceArray = @()
$device1 = new-object -TypeName "PSObject" -Prop (@{'Name'= "NAS"; 'IP'="10.1.4.4"})
$DeviceArray += $device1
$device2 = new-object -TypeName "PSObject" -Prop (@{'Name'= "Forinet Web Firewall"; 'IP'="10.1.200.11"})
$DeviceArray += $device2

<#
$device3 = new-object -TypeName "PSObject" -Prop (@{'Name'= "RHABak01"; 'IP'="10.121.38.22"})
$DeviceArray += $device3
$device4 = new-object -TypeName "PSObject" -Prop (@{'Name'= "RHABak02"; 'IP'="10.73.232.203"})
$DeviceArray += $device4
#>

##loop through the devices testing ping and adding to report if any failed

$device_Fail_Count = 0
$device_count = 0
$device_String = write-output "<br>-----------------------------<br><b>" "Hardware Device Test" "</b><br>-----------------------------<br>"
foreach ($device in $DeviceArray)
	{
	$device_count++
	if (!(test-Connection -ComputerName $device.IP -Count 2 -Quiet ))
		{
		$device_Fail_Count++
		$device_String += write-output ($device.Name + " Uptime<br> Status: " + "[FAILED]")
		}
	if (($device_fail_count -gt 0) -and ($device_count -ge $DeviceArray.count))
		{
		$MasterList.Add($device_String)	
		}	
	}

#################################################
# MAIN SQL SERVER REPORT LOOP
# Loops through the list of servers to generate the reports
# on each server
##################################################
ForEach ($Server in $ServerList) 
{
#check if server is alive
if (test-Connection -ComputerName $Server -Count 2 -Quiet ) 
	{	
	net use /delete S: /yes
	net use S: \\$Server\HealthCheckLogs
	$MapTest = net use S:
	if  ($MapTest.Count -gt 0)
		{
		#Check if sql exists/is current
		$LastSQL = Get-ChildItem S:\SQL*.html | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastSQL))
			{
			#RemoteJob not running
			$SQLText = write-output "SQL Server Full<br>" "Status:          [NOT RUNNING]<br> " 
			}
			else
			{
			$SQLText = Get-Content $LastSQL
			}
		#check if the disk space file exists/is current
		$LastDisk = Get-ChildItem S:\Disk*.html | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastDisk))
			{
			#RemoteJob not running
			$DiskText = write-output "Disk Space Check<br>" "Status:          [NOT RUNNING]<br> " 
			}
			else
			{
			$DiskText = Get-Content $LastDisk
			}
		$LastService = Get-ChildItem S:\Service*.html | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastService))
			{
			#RemoteJob not running
			$ServiceText = write-output "Service Check<br>" "Status:          [NOT RUNNING]<br> " 
			}
			else
			{
			$ServiceText = Get-Content $LastService
			}
	
		$EmailText = output_compression $server ($ServiceText | out-string) ($DiskText | out-string) ($BUEText | out-string) ($SQLText | out-string) 
		}
	else 
		{
		$EmailText = write-output "<br>-----------------------------<br><b>" $server "</b><br>-----------------------------<br>" "<font color="red">Audit job unable to map drive on $Server</font>" "<br>Check the map drive password and share permsissions" "<br>"
		}
	}
else
	{
	#The server is not responding to the host check, it may be down
	#Create Email text for down server
	$EmailText = write-output "<b><font color="red">DANGER WILL ROBINSON!</font><br></b>" "<b><font color="red">$Server is down!</font><br></b>" "<b>CHECK ON THE STATUS OF $SERVER!!</b><br>" "Check to ensure that ping is enabled for this machine!<br><br>"
	}

$MasterList.Add($EmailText)
}

################################################Non-SQL Servers###############################################

$RemoteServerList = Get-Content $RemoteServerListLocation
foreach ($RemoteServer in $RemoteServerList)
{
	if (test-Connection -ComputerName $RemoteServer -Count 2 -Quiet ) 
	{
		$DiskFileName = $RemoteDiskFileLoc + "Disk-" + $RemoteServer + ".txt"
		$LastDisk = Get-ChildItem $DiskFileName | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastDisk))
			{
			#RemoteJob not running
			$DiskText = write-output "Disk Space Check<br>" "Status:          [NOT RUNNING]<br> " 
			}
			else
			{
			$DiskText = Get-Content $LastDisk
			}
		
		$ServiceFileName = $RemoteServiceFileLoc + "Service-" + $RemoteServer + ".txt"
		$LastService = Get-ChildItem $ServiceFileName | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastService))
			{
			#RemoteJob not running
			$ServiceText = write-output "Service Check<br>" "Status:          [NOT RUNNING]<br> " 
			}
			else
			{
			$ServiceText = Get-Content $LastService
			}
	    $EmailText =  output_compression $RemoteServer ($LastService | out-string) ($LastDisk | out-string) 
    }
	else
	{
		#The server is not responding to the host check, it may be down
		#Create Email text for down server
		$EmailText = write-output "<b>$RemoteServer is down!<br></b>" "<b>CHECK ON THE STATUS OF $REMOTESERVER!!</b><br>" "Check to ensure that ping is enabled for this machine<br><br>" 
	}
$MasterList.Add($EmailText)
}



################################################Emails, the Emails###############################################

$body = $MasterList | Out-String

$Failed=@"
<font color="red"><b>FAILED</b></font>
"@

$OK=@"
<font color="#66FF33"><b>OK</b></font>
"@

$NR=@"
<font color="red"><b>NOT RUNNING</b></font>
"@

$WRN=@"
<font color="#FFCC33"><b>Warning</b></font>
"@

$REBOOT=@"
<font color="#FF00FF"><b>REBOOT REQUIRED</b></font>
"@

# <font color="red">This is some text!</font> 
$body = $body -replace "FAILED",$Failed
$body = $body -replace "OK",$OK
$body = $body -replace "NOT RUNNING",$NR
$body = $body -replace "Warning",$WRN
$body = $body -replace "Reboot Required",$REBOOT


write-output $body > $MasterTextFile

$smtpServer = "Cheech"
$smtpFrom = "HealthCheck@Rush.edu"
#$smtpTo == @("Kevin_F_Tobola@rush.edu", "Torsten_Spooner@rush.edu", "Matthew_Wright@rush.edu")
#$smtpTo = "Alerts@rush-health.com"
$messageSubject = "PhotobooksStatusReport"

$smtpTo = "Torsten_Spooner@rush.edu"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -BodyAsHtml -smtpServer "$smtpserver"

$smtpTo = "Kevin_F_Tobola@rush.edu"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -BodyAsHtml -smtpServer "$smtpserver"

$smtpTo = "Matthew_Wright@rush.edu"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -BodyAsHtml -smtpServer "$smtpserver"	

################################################Fill out Reboot Reports##########################################

$reboot_report = @()
$reboot_report+= "There are planned server reboots for this upcoming Monday"
$nextMonday = (Get-Date).AddDays(+5)
if ($Reboot_430_List.Count -gt 0)
    {
    #writes to reboot 430 list file
    write-output $Reboot_430_List > $430_file
    $reboot_report+= write-output "" ("The following servers are slated to be rebooted at 04:30 EST on " + $nextMonday ) "" $Reboot_430_List
    }


if ($Reboot_4AM_List.Count -gt 0)
    {
    #writes to reboot 400 list file
    write-output $Reboot_4AM_List > $4AM_file
    $reboot_report+= write-output "" ("The following servers are slated to be rebooted at 04:00 EST on " + $nextMonday ) "" $Reboot_4AM_List
    }
	

if ($Reboot_5AM_List.Count -gt 0)
    {
    #writes to reboot 500 list file
    write-output $Reboot_5AM_List > $5AM_file
    $reboot_report+= write-output "" ("The following servers are slated to be rebooted at 05:00 EST on " + $nextMonday ) "" $Reboot_5AM_List
    }	


if (($Reboot_430_List.Count -gt 0) -or ($Reboot_4AM_List.Count -gt 0) -or ($Reboot_5AM_List.Count -gt 0))
{
    $smtpServer = "Cheech"
    $smtpFrom = "HealthCheck@Rush-Health.com"
    $rebootSubject = "Upcoming Server Reboots: Photobooks"
    $rebootbody = $reboot_report | Out-String

    $smtpTo = "ServerReboots@rush-health.com"
    send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$rebootSubject" -body "$rebootbody" -smtpServer "$smtpserver"

<#
    $smtpTo = "Panagiotis_Kourtidis@rush.edu"
    send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$rebootSubject" -body "$rebootbody" -smtpServer "$smtpserver"

    $smtpTo = "Nagaranjan_Chevula@rush.edu"
    send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$rebootSubject" -body "$rebootbody" -smtpServer "$smtpserver"

    $smtpTo = "Raymond_J_Halper@rush.edu"
    send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$rebootSubject" -body "$rebootbody" -smtpServer "$smtpserver"
#>
}