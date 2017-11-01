##########################################################################################
# Pending Reboot Check 
# version 1.0
# 01/16/2017
# Changes: 
# Added coloring, bold, and italics to script
# Changed output type to HTML
# rewrote registry check to use variables for readability
##########################################################################################

#####################################################
# Does the HTML coloring
#####################################################
$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@

$REBOOT=@"
[<font color="#FF00FF"><b>REBOOT REQUIRED</b></font>]<br>
"@

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

write-output $ReportMessage2 >> C:\Temp\Pending-Reboots.html