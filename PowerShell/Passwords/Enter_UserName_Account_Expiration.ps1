$UserName  = Read-Host 'Enter UserName'
Get-ADUser -identity $UserName -Properties msDS-UserPasswordExpiryTimeComputed | select samaccountname,@{ Name = "Expiration Date"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | FT
Pause;