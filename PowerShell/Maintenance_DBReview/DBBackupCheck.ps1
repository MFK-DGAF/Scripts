import-module sqlps
####################################
# Variables
####################################
$Email_Address = "Name@email.com"
$Email_Name = "Name"

$smtpServer = "Server"
$smtpFrom = "DatabaseCheck@email.com"
$DBSubject = write-output ("Databases on " + $env:COMPUTERNAME + "  are not being backed up")

##Email strings 
$HaveNotStr = write-output (",<br><br>The following databases on " + $env:COMPUTERNAME + " have not been backed up in the past month:<br><br>" )
$pleaseContact  = "<br>Please contact your support team and/or DBA to let them know which databases to backup or not inform you about next month.<br>"
$regards = "<br>Regards,<br><br>The monthly backup check job. "

$MostRecent = dir SQLSERVER:\SQL\localhost\DEFAULT\DATABASES | SELECT Name, Status, LastBackupDate 
$FailList = new-object system.collections.arraylist


ForEach ($ForEachCounter in $MostRecent)
{
    if((Get-Date).AddDays(-30) -gt $ForEachCounter.LastBackupDate)
    {
        $FailList += $ForEachCounter.Name + "<br>"
    }
}

if ($FailList.Count -gt 0)
{
    $failstring = $FailList | Out-String
    if ($failstring -ne "")
    {
        $mailmessage = write-output ($Email_Name + $HaveNotStr + $failstring + $pleaseContact + $regards)
        send-mailmessage -from "$smtpFrom" -to "$Email_Address" -subject "$DBSubject" -body "$mailmessage" -BodyAsHtml -smtpServer "$smtpServer"
    }
}




