param([string]$BackupDir = "G:\backups", [int]$Age = 7, $FileType = ("*.zip", "*.bak", "*.bz2"))
{
    $date = get-date
    $date = $date.AddDays(-$Age)
    get-childitem -recurse $BackupDir -include $filetype | where { $_.LastWriteTime -lt $date } | Remove-Item  
    get-childitem -recurse $BackupDir -include "*.trn*" | Remove-Item 
}  