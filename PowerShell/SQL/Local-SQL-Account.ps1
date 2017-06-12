#This script will create a local SQL server Auth. Account
#import SQL Server module
Import-Module SQLPS -DisableNameChecking

$instanceName = "."
$loginName = Read-Host "Enter Username"
$password = "abcd!1234"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

# drop login if it exists
if ($server.Logins.Contains($loginName))  
{   
    Write-Host("Deleting the existing login $loginName.")
       $server.Logins[$loginName].Drop() 
}

$login = New-Object `
-TypeName Microsoft.SqlServer.Management.Smo.Login `
-ArgumentList $server, $loginName
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
$login.PasswordExpirationEnabled = $false
$login.Create($password)
Write-Host("Login $loginName created successfully.")