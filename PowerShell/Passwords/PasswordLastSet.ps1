$User = Read-Host 'User'
Get-ADUser -Identity $User -Properties * |ft Name,PasswordLastSet,AccountExpirationDate
Pause;