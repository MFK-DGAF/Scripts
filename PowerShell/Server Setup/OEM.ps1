WMIC COMPUTERSYSTEM GET MANUFACTURER | Out-File c:\tmp\Manufacturer.txt
WMIC COMPUTERSYSTEM GET MODEL | Out-File c:\tmp\Model.txt
#Get-WmiObject Win32_ComputerSystem | Out-File c:\tmp\test.txt