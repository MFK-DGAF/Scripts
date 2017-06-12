#Get Computer Name
$computerName = Get-WmiObject Win32_ComputerSystem

#Ask for New Computer Name
$name = Read-Host "Please Enter The Computer Name For This System"

#Set New Computer Name
$computername.Rename($name)