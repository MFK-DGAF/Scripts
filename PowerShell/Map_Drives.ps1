$DomainName = [Environment]::UserDomainName
$UserName = [Environment]::UserName
$Login = ($DomainName + $UserName)

$Username = [Environment]::UserName
$Firstletter = $Username.Substring(0,1)


If 