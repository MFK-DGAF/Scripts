$XMLText = new-object system.collections.arraylist
$Flag = ""
Do {
    $DomainName = Read-Host  "Enter DomainName or Enter to quit"
    if ($DomainName -ne "")
        {
    	    $UserName = Read-Host  "Enter Username or Enter to quit"
	        if ($UserName -ne "")
	        {
		        $Password = Read-Host "Password" -AsSecureString | ConvertFrom-SecureString
		        $AccountCreds = write-output "<Configuration>" ("<DomainName>" + $DomainName + "</DomainName>") ("<UserName>" + $UserName + "</UserName>") ("<Password>" + $Password + "</Password>") "</Configuration>"
		        $XMLText.Add($AccountCreds)	
		        $Flag = "1"
	        }
        }
    } While (($UserName -ne "") -AND ($domainName -ne ""))
if ($Flag -ne "")
{
$XMLComplete = write-output '<?xml version="1.0" encoding="utf-8" ?>' "<root>" $XMLText "</root>"
$XMLComplete | Set-Content "E:\automation\Maintenance_ScriptManager\CredentialsNew.xml"
}