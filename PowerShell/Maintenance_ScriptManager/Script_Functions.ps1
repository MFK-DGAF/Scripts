
. "E:\automation\Maintenance_ScriptManager\Get_Bak_Dir.ps1"
. "E:\automation\Maintenance_ScriptManager\SQL_Script_Functions.ps1"
. "E:\automation\Maintenance_ScriptManager\SQL_Query_Functions.ps1"


function CONVERT_DRIVEPATH_TO_URL ([string]$DrivePath, $ServerName)
{
$DrivePath = $DrivePath.Replace(":", "$")
$URLPath = write-output ("\\" + $ServerName + "\" + $DrivePath)

return $URLPath
}

function GET_DOMAIN_CRED_FROM_XML ([string]$DomainName, [string]$XMLPath = "E:\automation\Maintenance_ScriptManager\CredentialsNew.xml")
{
    [xml]$Accounts = Get-Content $XMLPath
    foreach ($node in $Accounts.root.Configuration)
    {
        if ($node.DomainName -eq $DomainName)
        {
            $Password = ConvertTo-SecureString $node.Password
            $UserName = write-output ($DomainName + "\" + $node.Username)
            $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $Password
        }
    }
    return $cred
}

function GET_HASH ($JobName, $ScriptName, $ServerName, [switch]$RawPath)
{
    $ServerInfo = GET_SERVER_INFO -ServerName $ServerName
    $scriptPath = CONVERT_DRIVEPATH_TO_URL -DrivePath $ServerInfo.ScriptDir -ServerName $ServerInfo.Name
    $cred = GET_DOMAIN_CRED_FROM_XML $ServerInfo.Domain
    
    #if the Rawpath flah is set, it ignores the scriptdir, and uses the input location as the whole path
    if ($RawPath)
    {
        $filePath = write-output ($JobName + "\" + $ScriptName)
        $driveMapoutput = New-PSDrive -name Y -PSProvider FileSystem -root $JobName -Credential $cred -Persist
    }
    else
    {
        $filepath = Write-Output ($scriptPath + "\" + $JobName + "\" + $ScriptName)
        $driveMapoutput = New-PSDrive -name Y -PSProvider FileSystem -root $scriptPath -Credential $cred -Persist
    }
    
    #if the file exists, get MD5, otherwise, return 0
    if (test-path $filepath)
    {
        $hash = Get-FileHash -LiteralPath $filePath -Algorithm MD5
        $hashvalue = write-output ($hash.Hash)
    }
    else 
    {
        $hashvalue = 0
    }
    #checks to see if the drive was mapped, and removes it
    if (Get-PSDrive | Where-Object { $_.name -eq "Y"} | Select-Object name)
    {
        $removeinfo = Remove-PSDrive -name Y
    }
    return $hashvalue
}

function GET_ALL_HASHES ($JobName, $ScriptName, $Domain = "")
{
    
    $serverList = GET_SERVER_LIST -Domain $Domain
    foreach ($Server in $serverList)
    {
        $scriptPath = CONVERT_DRIVEPATH_TO_URL -DrivePath $Server.ScriptDir -ServerName $Server.Name
        $cred = GET_DOMAIN_CRED_FROM_XML $Server.Domain
        
        $driveMapoutput = New-PSDrive -name W -PSProvider FileSystem -root $scriptPath -Credential $cred -Persist
        $filepath = Write-Output ($scriptPath + "\" + $JobName + "\" + $ScriptName)
        $hash = Get-FileHash -LiteralPath $filePath -Algorithm MD5
        write-output ($Server.Name + ", " + $ScriptName + ", " + $hash.Hash)
        
        #checks to see if the drive was mapped, and removes it
        if (Get-PSDrive | Where-Object { $_.name -eq "W"} | Select-Object name)
        {
            $removeinfo = Remove-PSDrive -name W
        }
    }
}

function GET_ALL_BAK_DIRS ($Domain = "")
{

    $serverlist = GET_SERVER_LIST -Domain $Domain

    cd "E:\automation\Maintenance_ScriptManager\"

    foreach ($server in $Serverlist)
    {
        $server.Name
        GET_BAK_DIR $server.Name
    }
}

function MIGRATE_FILE 
(
    [string]$File,
    [string]$DestDir, 
    [string]$Server, 
    [string]$Domain
)
{
    $DriveCheck = get-psdrive | where { $_.root -like "*$Server*" } 
    if (!($DriveCheck))
    {
        $creds = GET_DOMAIN_CRED_FROM_XML $Domain
        $mapOutput = New-PSDrive -name V -PSProvider FileSystem -Credential $creds -root $DestDir -Persist
    }

    $returnMessage = write-output ($Server + "file transfer") " "
    $DestFileName = $File.SubString($File.LastIndexOf("\"), ($File.Length - $File.LastIndexOf("\") ) )
    $DestFile = Write-output ($DestDir + $DestFileName)
    if (test-path $DestFile)
    {
        $archiveDir = write-output ($DestDir + "\archive\")
        
        if (!(test-path $archiveDir))
        {
            mkdir $archiveDir
        }
        $DateString = (get-date -Format yyyyMMdd).ToString()
        $archiveName = write-output ($ArchiveDir + $DestFileName.SubString(0, $DestFileName.LastIndexOf(".")) + "_old_" + $DateString + $DestFileName.SubString($DestFileName.LastIndexOf("."), ($DestFileName.Length - $DestFileName.LastIndexOf(".") ) )) 
                
        while (test-path $archiveName)
        {
            $counter++ 
            $archiveName = write-output ($ArchiveDir + $DestFileName.SubString(0, $DestFileName.LastIndexOf(".")) + "_old_" + $counter + "_" + $DateString + $DestFileName.SubString($DestFileName.LastIndexOf("."), ($DestFileName.Length - $DestFileName.LastIndexOf(".") ) )) 
        }
        
        Move-Item $DestFile $archiveName
        $returnMessage += write-output ("the existing file was achived as " + $archiveName) 
    }
    
    Copy-Item $File $DestDir
    $returnMessage += write-output ($destFileName + " has been copied")
    
    #checks to see if the drive was mapped, and removes it
    if (Get-PSDrive | Where-Object { $_.name -eq "V"} | Select-Object name)
    {
        $removeinfo = Remove-PSDrive -name V
    }

    return $returnMessage
}
