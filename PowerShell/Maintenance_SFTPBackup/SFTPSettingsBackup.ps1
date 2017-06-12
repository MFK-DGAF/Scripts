If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
$NASString = "\\10.1.4.4\backup02_27tb\SFTP_Config\Hermes\"
$BackupString = $NASString
$BackupString += "HermesSFTPSettings_" 
$BackupString += Get-Date -Format yyyy_MM_dd
$BackupString += ".txt"

$cfg = new-object -com "BssCfg712.BssCfg712"
$cfg.LoadServerSettings()
$cfg.settings.Dump("`$cfg", $cfg.OmitDefaults.yes) > $BackupString




