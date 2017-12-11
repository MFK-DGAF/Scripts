#####################################################
# Check if reboot registry entries exist
#####################################################

If ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue) -Or (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "RebootRequired") -Or (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Name "RebootPending"))
{
$ReportMessage2 = write-output ("Pending Reboot<br>") ("Status:          [REBOOT REQUIRED]<br>")
}
else
{
$ReportMessage2 = write-output ("Pending Reboot<br>") ("Status:          [OK]<br>")
}


write-output $ReportMessage2 >> C:\temp\Reboot.txt

#####################################################
# Check if reboot registry entries exist
#####################################################

$Reg1 = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
$RegKey1= $Reg1.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations")
$Reg2 = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
$RegKey2= $Reg2.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
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

write-output $ReportMessage2 >> C:\temp\Reboot2.txt