param(
	[string]$BackupDir = "F:\backups", 
	[int]$Age = 14 
	)

$CurrentDate = Get-Date
$Date = $CurrentDate.AddDays(-$Age)
Get-ChildItem $BackupDir -Recurse -include *.bak, *zip | Where-Object { $_.LastWriteTime -lt $Date } | Remove-Item 