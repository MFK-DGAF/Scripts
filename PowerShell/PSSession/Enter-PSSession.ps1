$cred = Get-Credential
Enter-PSSession -ComputerName "10.0.0.8" -Credential $cred
#I have the session power!
Exit-pssession
