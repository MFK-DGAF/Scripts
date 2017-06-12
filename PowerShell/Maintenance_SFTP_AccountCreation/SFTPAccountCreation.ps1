##############################################################
##Ensures that the script is running as administrator
###############################################################
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

###############################################################
#Sets Variables 
#Password needs to be saved as secure string
###############################################################
$UserName = Read-Host "Username:"
$SFTPPath = Read-Host "SFTP Directory:"
$PasswordString = Read-Host "Password:" -AsSecureString
$contact = Read-host "Contact Name:"
$Email = Read-host "Contacts email:"
$phone = read-host "Contacts phone:"
$LocalExpert = read-host "Who at rush tracks this account?:"
# -OtherAttributes @{info=$args[3]}

$ADServer = "Luigi-SPADFS2"

################################################################
#Remotes into the Luigi-SPADFS2 to run AD commands
#Adds user
#Attaches user to Hermes_SFTP group
################################################################
#Enter-PSSession -ComputerName Luigi-SPADFS2
invoke-command -ComputerName $ADServer -ScriptBlock {New-ADUser -Name $args[0] -AccountPassword $args[1] -Description $args[2] -ChangePasswordAtLogon $false -Path "ou=SFTP_Users,DC=rhadata,DC=rushhealthassociates,dc=com" -Enabled $true -PasswordNeverExpires $true} -args $UserName, $PasswordString, $SFTPPath

invoke-command -ComputerName $ADServer -ScriptBlock {Add-ADGroupMember -Identity Hermes_SFTP -Member $args[0]} -ArgumentList $UserName
#Exit-PSSession

##############################################################
#if the directory does not exist, it creates it
#Gives the user rights to the directory
###############################################################
If (!(Test-Path $SFTPPath))
{
	New-Item -ItemType Directory -Force -Path $SFTPPath
}
$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

###############################################################
#Adds SFTP Settings to Hermes instance of BitViseSSH
###############################################################

$cfg = new-object -com "BssCfg712.BssCfg712"
$cfg.LockServerSettings()
$cfg.LoadServerSettings()
$cfg.settings.access.winAccountsEx.new.SetDefaults()
$cfg.settings.access.winAccountsEx.new.winAccountType = 2
$cfg.settings.access.winAccountsEx.new.winDomain = "RHADATA"
$cfg.settings.access.winAccountsEx.new.winAccount = $UserName
$cfg.settings.access.winAccountsEx.new.loginAllowed = $cfg.DefaultYesNo.yes
$cfg.settings.access.winAccountsEx.new.xfer.mountPointsEx.Clear()
$cfg.settings.access.winAccountsEx.new.xfer.mountPointsEx.new.realRootPath = $SFTPPath
$cfg.settings.access.winAccountsEx.new.xfer.mountPointsEx.NewCommit()
$cfg.settings.access.winAccountsEx.NewCommit()
$cfg.SaveServerSettings()
$cfg.UnlockServerSettings()
Pause;