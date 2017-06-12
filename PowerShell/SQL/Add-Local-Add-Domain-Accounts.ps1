#This script will create a local SQL server Auth. Account
#import SQL Server module
Import-Module SQLPS -DisableNameChecking

$instanceName = "."
$localName = Read-Host "Enter Local Username"
$password = "abcd!1234"
$domainname = write-output (“RHAEDW1\” + $localname)

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName


$login = New-Object `
-TypeName Microsoft.SqlServer.Management.Smo.Login `
-ArgumentList $server, $localName
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($password)
Write-Host("Login $localName created successfully.")

$login = New-Object `
-TypeName Microsoft.SqlServer.Management.Smo.Login `
-ArgumentList $server, $domainName
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
$login.Create()
Write-Host("Login $DomianName created successfully.")