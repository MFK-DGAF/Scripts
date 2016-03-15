$ServiceList = get-service -include MSSQLServer, BackupExecManagementService, SQLServerAgent, TermService, MSSqlServerOLAPService, W3Svc

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
{$ReportMessage = write-output ("Host Services") ("Status:          [OK]")}
else
{$ReportMessage = write-output ("Host Services") ("Status:          [FAIL]") ("The following services are not running: " + $FailList)}

write-output $ReportMessage > F:\BackupAudit\Service-PHOSQL03.txt

If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
{
$ReportMessage2 = write-output ("Pending Reboot") ("Status:          [REBOOT REQUIRED]")
}
else
{
$ReportMessage2 = write-output ("Pending Reboot") ("Status:          [OK]")
}


write-output $ReportMessage2 >> F:\BackupAudit\Service-PHOSQL03.txt