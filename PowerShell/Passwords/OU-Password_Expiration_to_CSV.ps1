Import-Module ActiveDirectory
Get-ADUser -SearchBase "OU=RHA,OU=CORP,OU=CAMPUS,DC=rush,DC=edu"`
 -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} `
–Properties "SamAccountName","msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "SamAccountName", @{Name="Password Expiry Date";`
Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} |
Export-CSV "C:\tmp\PasswordExpirationReport.csv" -NoTypeInformation -Encoding UTF8
Pause;