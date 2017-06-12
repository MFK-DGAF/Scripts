param(
[string]$outputDir = "E:\HealthCheckLogs",
[string]$serviceListFile = "D:\automation\Maintenance_HealthCheck\ServiceList.txt"
)

##########################################################################################
# Service Check 
# version 1.0
# 01/16/2017
# Changes: 
# Added Parameters for Service File & output dir
# Added coloring, bold, and italics to script
# Changed output type to HTML
# rewrote registry check to use variables for readability
##########################################################################################

$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@

$REBOOT=@"
[<font color="#FF00FF"><b>REBOOT REQUIRED</b></font>]<br>
"@


$outputFile = write-output ($outputDir + "\Service-" + $env:ComputerName + ".html")

if ($serviceListFile -eq "")
{
    $serviceListRaw = ("MSSQLServer", "TermServer", "SQLServerAgent")
}
else
{
    $serviceListRaw = get-content $serviceListFile
}

$ServiceList = get-service -include $ServiceListRaw 

Foreach ($Service in $Servicelist)
{
if ($Service.Status -ne "Running")
    {
        $failcount = $failcount + 1
        if ($failcount -eq 1) 
        {
            $faillist = write-output ("<i>" + $service.Name + "</i><br>")
        }
        else
        {
        $faillist = write-output ($faillist + ", " + $Service.Name)
        }
    }
}

if ($failcount -le 0)
{$ReportMessage = write-output ("<b>Host Services</b><br>") ("Status:          " + $OK)}
else
{$ReportMessage = write-output ("<b>Host Services</b><br>") ("Status:          " + $Fail) ("The following services are not running: " + $FailList)}

write-output $ReportMessage > $outputFile

#####################################################
# Check if reboot registry entries exist
#####################################################

$Reg1 = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
$RegKey1= $Reg1.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations")
$Reg2 = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
$RegKey2= $Reg2.OpenSubKey("SYSTEM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
$Reg3 = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
$RegKey3 = $Reg3.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")

if (($RegKey1 -eq $null) -and ($RegKey2 -eq $null) -and ($RegKey3 -eq $null))
{
$ReportMessage2 = write-output ("<b>Pending Reboot</b><br>") ("Status:          " + $OK)
}
else
{
$ReportMessage2 = write-output ("<b>Pending Reboot</b><br>") ("Status:          " + $REBOOT)
}

write-output $ReportMessage2 >> $outputFile

