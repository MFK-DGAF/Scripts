$SFTPFolders = Get-ChildItem C:Homefolders -Directory
foreach ($SFTPFolder in $SFTPFolders) {
    $Path = $SFTPFolder.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $SFTPFolder.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}