$UserName = 'kvtobola'
$SFTPPath = 'C:\TEMP\Test'

If (!(Test-Path $SFTPPath))
{
	New-Item -ItemType Directory -Force -Path $SFTPPath
}
$Acl = (Get-Item $SFTPPath).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
$Acl.SetAccessRule($Ar)
Set-Acl -path $SFTPPath -AclObject $Acl