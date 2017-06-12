$domain = Read-Host -Prompt "Enter FQDN"
$user = Read-Host -Prompt "Enter Username" 
#Don't edit below this point 
$password = Read-Host -Prompt "Enter password for $user" -AsSecureString 
$username = "$domain\$user" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
Add-Computer -DomainName $domain -Credential $credential