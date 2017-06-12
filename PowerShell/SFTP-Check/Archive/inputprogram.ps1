$XMLText = new-object system.collections.arraylist
$Flag = ""
Do {
	$UserName = Read-Host  "Enter Username or Enter to quit"
	if ($UserName -ne "")
	{
		$Password = Read-Host "Password" -AsSecureString | ConvertFrom-SecureString
		$AccountCreds = write-output "<Configuration>" ("<UserName>" + $UserName + "</UserName>") ("<Password>" + $Password + "</Password>") "</Configuration>"
		$XMLText.Add($AccountCreds)	
		$Flag = "1"
	}
} While ($UserName -ne "")
if ($Flag -ne "")
{
$XMLComplete = write-output '<?xml version="1.0" encoding="utf-8" ?>' "<root>" $XMLText "</root>"
$XMLComplete | Set-Content "E:\automation\SFTPTest\CredentialsNew.xm"
}