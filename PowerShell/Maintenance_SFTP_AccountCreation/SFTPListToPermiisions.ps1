##imports the file that contains the SFTP configuration
##pulls out the lines with the usernames and directories
##Exports a | delimited list of usernames and directories

$SFTPConfigFile = "c:\users\tspooner\Desktop\HermesSFTPsettingsTestcopy.txt" 
$AccountFile = "C:\users\tspooner\Desktop\Testout.txt"
$AccountList = get-content $SFTPConfigFile | Select-String -pattern '(winAccountsEx.new.winAccount )|(realRootPath)' 
$ListCount = 0
$nl = [Environment]::NewLine
foreach ($ListItem in $AccountList)
{
	$ListItem = $ListItem.ToString()
	if ($ListCount -eq 2)
	{
		$ListItem = $ListItem.Replace('$cfg.access.winAccountsEx.new',"")
		$ListItem = $ListItem.Replace('.winAccount = ', "")
		$ListItem = $ListItem.Replace('.xfer.mountPointsEx.new.realRootPath = ', "|")
		#$ListItem | out-file C:\users\tspooner\Desktop\Testout.txt -Enc ascii
		[io.file]::WriteAllText("C:\users\tspooner\Desktop\Testout.txt",$ListItem)
	}
	if ($ListCount -gt 2)
	{
		$ListItem = $ListItem.Replace('$cfg.access.winAccountsEx.new',"")
		if ($ListItem.Contains("winAccount"))
		{
			$ListItem = $ListItem.Replace('.winAccount = ', $nl)
		}
		else
		{
			$ListItem = $ListItem.Replace('.xfer.mountPointsEx.new.realRootPath = ', "|")
		}
		#$ListItem | out-file C:\users\tspooner\Desktop\Testout.txt -Enc ascii -Append
		[io.file]::AppendAllText($AccountFile ,$ListItem)
		}
	$ListCount = $ListCount + 1
}


$AccountArray = import-csv $AccountFile -delimiter "|" -Header Username, Path


##code to set the permissions
foreach ($Account in $AccountArray) 
{
    $Path = $Account.Path
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $Account.Username
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl

 }