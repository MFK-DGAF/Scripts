$XMLText = new-object system.collections.arraylist
$Flag = ""
Do {
	$UserName = Get-Content "./username.txt"
	if ($UserName -ne "")
	{
		$Password = Get-Content "./password.txt" -AsSecureString | ConvertFrom-SecureString
		$AccountCreds = write-output "<Configuration>" ("<UserName>" + $UserName + "</UserName>") ("<Password>" + $Password + "</Password>") "</Configuration>"
		$XMLText.Add($AccountCreds)	
		$Flag = "1"
	}
} While ($UserName -ne "")
if ($Flag -ne "")
{
$XMLComplete = write-output '<?xml version="1.0" encoding="utf-8" ?>' "<root>" $XMLText "</root>"
$XMLComplete | Set-Content "./CredentialsNew.xml"
}