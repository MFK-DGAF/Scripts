$WorkingDir = "E:\automation\Maintenance_SSH"
$path = write-output ($workingdir + "\Credentials_" + $Env:UserName  + ".xml")

$XMLText = new-object system.collections.arraylist


$UserName = Read-Host  "Enter Username"
$Password = Read-Host "Password" -AsSecureString | ConvertFrom-SecureString
$AccountCreds = write-output ("<UserName>" + $UserName + "</UserName>") ("<Password>" + $Password + "</Password>")
$XMLText.Add($AccountCreds)	
$XMLComplete = write-output '<?xml version="1.0" encoding="utf-8" ?>' "<root>" $XMLText "</root>"
$XMLComplete | Set-Content $path
