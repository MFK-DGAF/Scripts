#list of servers
$ServerList = Get-Content E:\automation\HealthCheck\Serverlist.txt
# array of servers with servername and the text for the email
$MasterList = new-object system.collections.arraylist

ForEach ($Server in $ServerList) 
{
#check if server is alive
if (test-Connection -ComputerName $Server -Count 2 -Quiet ) 
	{	
	net use /delete S: /yes
	if ($Server -Match "pmmc"){
		net use S: \\$Server\BackupAudit L0gSh@r3 /user:pmmc6\Logshare}
	else			  {
		net use S: \\$Server\BackupAudit L0gSh@r3 /user:$Server\Logshare}
	
	$MapTest = net use S:
	if  ($MapTest.Count -gt 0)
		{
		#Check if BUE exists/is current
		$LastBUE = Get-ChildItem S:\BUE*.txt | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastBUE))
			{
			#RemoteJob not running
			$BUEText = write-output "Backup Exec Full" "Status:          [NOT RUNNING] " #("Job last run on: " 
			}
			else
			{
			$BUEText = Get-Content $LastBUE
			}
		#Check if sql exists/is current
		$LastSQL = Get-ChildItem S:\SQL*.txt | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastSQL))
			{
			#RemoteJob not running
			$SQLText = write-output "SQL Server Full" "Status:          [NOT RUNNING] " 
			}
			else
			{
			$SQLText = Get-Content $LastSQL
			}
		#check if the disk space file exists/is current
		$LastDisk = Get-ChildItem S:\Disk*.txt | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastDisk))
			{
			#RemoteJob not running
			$DiskText = write-output "Disk Space Check" "Status:          [NOT RUNNING] " 
			}
			else
			{
			$DiskText = Get-Content $LastDisk
			}
		$LastService = Get-ChildItem S:\Service*.txt | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastService))
			{
			#RemoteJob not running
			$ServiceText = write-output "Service Check" "Status:          [NOT RUNNING] " 
			}
			else
			{
			$ServiceText = Get-Content $LastService
			}
	
		$EmailText = write-output "-----------------------------" $server "-----------------------------" "" $BUEText $SQLText $DiskText $ServiceText ""
		}
	else 
		{
		$EmailText = write-output $server "" "Audit job unable to map drive on $Server" "Check the map drive password and share permsissions" ""
		}
	}
else
	{
	#The server is not responding to the host check, it may be down
	#Create Email text for down server
	$EmailText = write-output "$Server is down!" "CHECK ON THE STATUS OF $SERVER!!" "Check to ensure that ping is enabled for this machine"
	}

$MasterList.Add($EmailText)
}

################################################Non-SQL Servers###############################################

$RemoteServerList = Get-Content E:\automation\HealthCheck\Remote\NOSQLServerlist.txt
foreach ($RemoteServer in $RemoteServerList)
{
	if (test-Connection -ComputerName $RemoteServer -Count 2 -Quiet ) 
	{
		$DiskFileName = "F:\BackupAudit\Remote\Disk-" + $RemoteServer + ".txt"
		$LastDisk = Get-ChildItem $DiskFileName | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastDisk))
			{
			#RemoteJob not running
			$DiskText = write-output "Disk Space Check" "Status:          [NOT RUNNING] " 
			}
			else
			{
			$DiskText = Get-Content $LastDisk
			}
		
		$ServiceFileName = "F:\BackupAudit\Remote\Service-" + $RemoteServer + ".txt"
		$LastService = Get-ChildItem $ServiceFileName | Where{$_.LastWriteTime -ge (Get-Date).AddDays(-3)}
		if ([string]::IsNullOrEmpty($LastService))
			{
			#RemoteJob not running
			$ServiceText = write-output "Service Check" "Status:          [NOT RUNNING] " 
			}
			else
			{
			$ServiceText = Get-Content $LastService
			}

		$EmailText = write-output "-----------------------------" $RemoteServer "-----------------------------" "" $DiskText $ServiceText ""
	}
	else
	{
		#The server is not responding to the host check, it may be down
		#Create Email text for down server
		$EmailText = write-output "$RemoteServer is down!" "CHECK ON THE STATUS OF $REMOTESERVER!!" "Check to ensure that ping is enabled for this machine" " "
	}
$MasterList.Add($EmailText)
}



################################################Emails, the Emails###############################################


$smtpServer = "phosql-staging"
$smtpFrom = "HealthCheck@RushHealth.com"
#$smtpTo == @("Kevin_F_Tobola@rush.edu", "James_M_Williams33@rush.edu", "Torsten_Spooner@rush.edu")
$messageSubject = "FullStatusReport"
$body = $MasterList | Out-String
$smtpTo = "Torsten_Spooner@rush.edu"

send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"

$smtpTo = "Kevin_F_Tobola@rush.edu"

send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"

$smtpTo = "James_M_Williams33@rush.edu"

send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"
	