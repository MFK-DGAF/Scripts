Get-Content "./password.txt" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "./Passwordhashed.txt"
Pause