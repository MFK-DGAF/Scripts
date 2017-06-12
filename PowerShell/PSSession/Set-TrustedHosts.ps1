#You need to run as admin to tweak the WSMAN client settings. The WSMan service also needs to be running
#(on your client, that is)
cd WSMan:\localhost\Client
Set-Item .\TrustedHosts -Value "*" -Force