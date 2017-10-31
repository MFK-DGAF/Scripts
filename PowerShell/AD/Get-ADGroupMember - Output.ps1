$GroupName = Read-Host = "Enter the AD Group Name"
Get-ADGroupMember -Identity $GroupName | Get-ADObject -Properties Name, Cn | Ft Name, Cn
Write-Output $A > C:\Temp\$GroupName.txt