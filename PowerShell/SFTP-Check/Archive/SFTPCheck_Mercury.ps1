param (
    $localPath = "E:\automation\SFTPTest\Files\",
    $remotePath = "/",
    $credfile = "E:\automation\SFTPTest\Credentials.xml",
    $fileName = "testfile.txt"
)
         
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "E:\automation\SFTPTest\WinSCPnet.dll"
 	[xml]$Accounts = Get-Content $credfile
	#### Setup session options ####
	$sessionOptions = New-Object WinSCP.SessionOptions
	$sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
    	$sessionOptions.HostName = "mercury.photobooks.com"
	$sessionOptions.SshHostKeyFingerprint = "ssh-dss 1024 d2:37:0e:6e:8e:14:a8:de:39:e1:77:7d:d1:12:61:70"
	foreach ($node in $Accounts.root.Configuration)
	{	
 		$sessionOptions.UserName = $node.UserName
    		$sessionOptions.SecurePassword = ConvertTo-SecureString $node.Password
    		##$sessionOptions
		$session = New-Object WinSCP.Session
		$session.DisableVersionCheck = 1
		$session.ExecutablePath = "E:\automation\SFTPTest\Winscp.exe"
		$AccountStatus = "[OK]"
		try
    		{
        		# Connect
        		$session.Open($sessionOptions)
			$AccountMessage = write-output ("SFTP Channel open success")
 			try
			{
				# Copy the test file into the root of the SFTP server	
				$transferOptions = New-Object WinSCP.TransferOptions
        			$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
        			$transferResult = $session.PutFiles("E:\automation\SFTPTest\Files\testfile.txt", "/", $False, $transferOptions)
 
        			# Throw on any error
        			$transferResult.Check()
 
        			try
				{
					# Delete the test file from the root of the SFTP server
					$session.RemoveFiles("/testfile.txt")
				}	
        			catch [Exception]
				{
					$AccountStatus = "[Fail]"
					$AccountMessage = write-output ($AccountMessage) ("Failed to delete copied file") ($_.Exception.Message)
				}
			}	
        		catch [Exception]
			{
				$AccountStatus = "[Fail]"
				$AccountMessage = write-output ($AccountMessage) ("Failed to copy file to remote server") ($_.Exception.Message)
			}
    		}
		catch [Exception]
		{
			$AccountStatus = "[Fail]"
			$AccountMessage = write-output ("SFTP Channel failed to open") ($_.Exception.Message)
		}	
    		finally
    		{
        		# Disconnect, clean up
       	 		$session.Dispose()
    		}
	$ReportMessage += write-output " " "===========================" $node.UserName "===========================" $AccountStatus
	if ($AccountStatus -ne "[OK]")
		{
		$ReportMessage += $AccountMessage
		}
	}
    	 
##exit 0
}
catch [Exception]
{
   $ReportMessage = write-output "Loading .net Assembly failed" $_.Exception.Message
    ##exit 1
}
finally
{
$ReportMessage | Set-Content "E:\automation\SFTPTest\Report.txt"
if ($ReportMessage -eq "")
{
	$ReportMessage = "There did not appear to be any tests of the SFTP accounts running in this run of the program. Please verify that the Accounts.txt file has usable data and run again."
}

####################################################Email Text##################################################
$smtpServer = "PHOSQL-STAGING"
$smtpFrom = "SFTPCheck@RushHealth.com"

$messageSubject = "Rush-Mercury SFTP Report"
$body = $ReportMessage | Out-String

$smtpTo = "Alerts@rush-health.com"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"

$smtpTo = "Panagiotis_Kourtidis@rush.edu"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"
}

