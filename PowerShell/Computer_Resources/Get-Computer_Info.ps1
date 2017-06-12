$CPName = Read-Host "Enter Computer Name"
Get-WmiObject -Class Win32_Bios -ComputerName $CPName
Get-WmiObject -Class Win32_ComputerSystem -ComputerName $CPName
Pause;