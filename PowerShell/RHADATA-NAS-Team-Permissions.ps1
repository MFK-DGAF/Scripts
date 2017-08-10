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
##BI
######################

$UserName = 'BI_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\BI_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Contracting
######################

$UserName = 'Contracting_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\Contracting_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##CPI
######################

$UserName = 'CPI_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\CPI_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##EDW
######################

$UserName = 'EDW_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\EDW_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##HIE
######################

$UserName = 'HIE_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\HIE_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Provider Services
######################

$UserName = 'Provider_Services_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\Provider_Services_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Quality
######################

$UserName = 'Quality_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\Quality_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Solutions
######################

$UserName = 'Solutions_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\Solutions_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

######################
##Web
######################

$UserName = 'Web_Team'
$SFTPPath = '\\10.1.4.4\Data\Team\Web_Team'

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl

$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'FullControl','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl