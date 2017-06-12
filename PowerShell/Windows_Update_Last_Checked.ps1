$ComputerName = Read-Host "Enter Computer Name"

Get-Hotfix -computername $ComputerName | Select HotfixID, Description, InstalledOn | Sort-Object InstalledOn
