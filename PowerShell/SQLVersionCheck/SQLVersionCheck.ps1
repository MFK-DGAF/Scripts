import-module sqlps

######################################################
#Sets Variables
######################################################
$SRCServerList = Get-Content E:\Automation\Maintenance_HealthCheck\HealthCheckMaster\Serverlist.txt
$DBName = "master"
$TheDate = Get-Date
$SQLVersionQuery=@"
SELECT @@Version
"@
# array of servers with servername and the text for the email
$MasterList = new-object system.collections.arraylist

######################################################
# Loop through the list of servers, and run the query 
######################################################

foreach ($SrcServerName in $SRCServerList)
{
$SQLVersion = invoke-sqlcmd -ServerInstance $SrcServerName -Database $DBName -Query $SQLVersionQuery
$device_String = write-output ($SrcServerName + "         " +  $SQLVersion.Column1)
$MasterList.Add($device_String)
}

######################################################
# Emails the emails, huh, huh the emails
#####################################################
$smtpServer = "cheech"
$smtpFrom = "HealthCheck@Rush-Health.com"
$messageSubject = "SQL Version List"
$body = "Rock the body" 
$body = $MasterList | Out-String
$smtpTo = "Alerts@rush-health.com"
send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"