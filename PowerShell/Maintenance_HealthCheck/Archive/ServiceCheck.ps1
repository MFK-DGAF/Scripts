$ServiceList = get-service -include IISAdmin, MSSQLServer, BackupExecManagementService, SQLServerAgent$STANDARD, TermService, "VShell SSH2", W3Svc

$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@

$REBOOT=@"
[<font color="#FF00FF"><b>REBOOT REQUIRED</b></font>]<br>
"@




Foreach ($Service in $Servicelist)
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

if ($failcount -le 0)
{$ReportMessage = write-output ("Host Services<br>") ("Status:              " + $OK)}
else
{$ReportMessage = write-output ("Host Services<br>") ("Status:              " + $Fail) ("The following services are not running: " + $FailList + "<br>")}

write-output $ReportMessage > C:\logdir\HealthCheck\Service-Rush-Mercury.txt

If ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue) -Or (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "RebootRequired"))
{
$ReportMessage2 = write-output ("Pending Reboot<br>") ("Status:          [REBOOT REQUIRED]<br>")
}
else
{
$ReportMessage2 = write-output ("Pending Reboot<br>") ("Status:          [OK]<br>")
}


write-output $ReportMessage2 >> C:\logdir\HealthCheck\Service-Rush-Mercury.txt