##############################################################
##Ensures that the script is running as administrator
###############################################################
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
######################
##A
######################

$UserName = 'User - A'
$SFTPPath = '\\10.1.4.4\Data\User\A'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##B
######################

$UserName = 'User - B'
$SFTPPath = '\\10.1.4.4\Data\User\B'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##C
######################

$UserName = 'User - C'
$SFTPPath = '\\10.1.4.4\Data\User\C'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##D
######################

$UserName = 'User - D'
$SFTPPath = '\\10.1.4.4\Data\User\D'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##E
######################

$UserName = 'User - E'
$SFTPPath = '\\10.1.4.4\Data\User\E'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##F
######################

$UserName = 'User - F'
$SFTPPath = '\\10.1.4.4\Data\User\F'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##G
######################

$UserName = 'User - G'
$SFTPPath = '\\10.1.4.4\Data\User\G'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##H
######################

$UserName = 'User - H'
$SFTPPath = '\\10.1.4.4\Data\User\H'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##I
######################

$UserName = 'User - I'
$SFTPPath = '\\10.1.4.4\Data\User\I'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##J
######################

$UserName = 'User - J'
$SFTPPath = '\\10.1.4.4\Data\User\J'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##K
######################

$UserName = 'User - K'
$SFTPPath = '\\10.1.4.4\Data\User\K'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##L
######################

$UserName = 'User - L'
$SFTPPath = '\\10.1.4.4\Data\User\L'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##M
######################

$UserName = 'User - M'
$SFTPPath = '\\10.1.4.4\Data\User\M'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##N
######################

$UserName = 'User - N'
$SFTPPath = '\\10.1.4.4\Data\User\N'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##O
######################

$UserName = 'User - O'
$SFTPPath = '\\10.1.4.4\Data\User\O'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##P
######################

$UserName = 'User - P'
$SFTPPath = '\\10.1.4.4\Data\User\P'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Q
######################

$UserName = 'User - Q'
$SFTPPath = '\\10.1.4.4\Data\User\Q'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##R
######################

$UserName = 'User - R'
$SFTPPath = '\\10.1.4.4\Data\User\R'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##S
######################

$UserName = 'User - S'
$SFTPPath = '\\10.1.4.4\Data\User\S'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##T
######################

$UserName = 'User - T'
$SFTPPath = '\\10.1.4.4\Data\User\T'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##U
######################

$UserName = 'User - U'
$SFTPPath = '\\10.1.4.4\Data\User\U'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##V
######################

$UserName = 'User - V'
$SFTPPath = '\\10.1.4.4\Data\User\V'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##W
######################

$UserName = 'User - W'
$SFTPPath = '\\10.1.4.4\Data\User\W'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##X
######################

$UserName = 'User - X'
$SFTPPath = '\\10.1.4.4\Data\User\X'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Y
######################

$UserName = 'User - Y'
$SFTPPath = '\\10.1.4.4\Data\User\Y'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Z
######################

$UserName = 'User - Z'
$SFTPPath = '\\10.1.4.4\Data\User\Z'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Read','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','None,None', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl
