param(

    $PathToKeePassFolder = "C:\Program Files (x86)\KeePass Password Safe 2",
    $outfile = (write-output ("E:\automation\SFTPTest\Credentials_" + [Environment]::UserName +  ".xml"))	
)
#Load all .NET binaries in the folder
(Get-ChildItem -recurse $PathToKeePassFolder|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName) } Catch{ }} ) | out-null

<#
.Synopsis
   Finds matching EntryToFind in KeePass DB
.DESCRIPTION
   Finds matching EntryToFind in KeePass DB using Windows Integrated logon
.EXAMPLE
   Example of how to use this cmdlet
   FindPasswordInKeePassDB -PathToDB "C:\Powershell\PowerShell.kdbx" -EntryToFind "MasterPassword"
#>

Function Find-PasswordInKeePassDB
{
    [CmdletBinding()]
    [OutputType([String[]])]

    param(

        $PathToDB =  (write-output ("E:\automation\SFTPTest\Files\SFTPHelperCreds_" + [Environment]::UserName + ".kdbx")),
        $EntryToFind = "master"
    )

    $PwDatabase = new-object KeePassLib.PwDatabase

    $m_pKey = new-object KeePassLib.Keys.CompositeKey
    $m_pKey.AddUserKey((New-Object KeePassLib.Keys.KcpUserAccount))

    $m_ioInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $m_ioInfo.Path = $PathToDB

    $IStatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger

    $PwDatabase.Open($m_ioInfo,$m_pKey,$IStatusLogger)

    
    $pwItems = $PwDatabase.RootGroup.GetObjects($true, $true)
    foreach($pwItem in $pwItems)
    {
        if ($pwItem.Strings.ReadSafe("Title") -eq $EntryToFind)
        {
            $pwItem.Strings.ReadSafe("Password")
        }
    }
    $PwDatabase.Close()

}

<#
.Synopsis
   Generates XML file for using with SFTPTest job
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
   KeeGrouptoXML -GroupToSearch "KeyPass_Foldername" -PasswordToDB myNonTopSeceretPasswordInClearText
.EXAMPLE
   Find password using Integrated logon to get master password and then use that to unlock and find the password in the big one.
   FindPasswordInKeePassDBUsingPassword -EntryToFind "domain\username" -PasswordToDB (FindPasswordInKeePassDB -EntryToFind "MasterPassword")
#>
function KeeGrouptoXML
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (
        # Path To password DB
        $PathToDB = "K:\Information Technology\Accounts\SFTPAccounts.kdbx",
        # Entry to find in DB
        $GroupToSearch = "Hermes",
        $OutputFile = "E:\automation\SFTPTest\CredentialsNew_KeyPass.xml",
        # Password used to open KeePass DB        
        [Parameter(Mandatory=$true)][String]$PasswordToDB
    )
    $XMLText = new-object system.collections.arraylist
    $PwDatabase = new-object KeePassLib.PwDatabase
    $m_pKey = new-object KeePassLib.Keys.CompositeKey
    $m_pKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($PasswordToDB)));
    $m_ioInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $m_ioInfo.Path = $PathToDB

    $IStatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger

    $PwDatabase.Open($m_ioInfo,$m_pKey,$IStatusLogger)

    
    $pwItems = $PwDatabase.RootGroup.GetObjects($true, $true)
    foreach($pwItem in $pwItems)
    {
        if (($pwItem.Strings.ReadSafe("Title") -ne "") -and ($pwItem.Strings.ReadSafe("Title") -ne $null) -and ($pwItem.Strings.ReadSafe("Password") -ne "") -and ($pwItem.Strings.ReadSafe("Title") -ne $null))
        {
            if ($pwItem.ParentGroup.Name -eq "Hermes")
            {
                $UserName = $pwItem.Strings.ReadSafe("Title")
                $SecPWD =  ConvertTo-SecureString -String $pwItem.Strings.ReadSafe("Password") -AsPlainText -Force
                $Password =  ConvertFrom-SecureString $SecPWD
		        $AccountCreds = write-output "<Configuration>" ("<UserName>" + $UserName + "</UserName>") ("<Password>" + $Password + "</Password>") "</Configuration>"
		        $XMLText.Add($AccountCreds)	
            }
        }
    }
    $PwDatabase.Close()
    $PasswordToDB = $null
    $XMLComplete = write-output '<?xml version="1.0" encoding="utf-8" ?>' "<root>" $XMLText "</root>"
    $XMLComplete | Set-Content $outputFile
    return
}

$maplist = net use
foreach ($mapitem in $maplist) 
{
    if ($mapitem -like "*10.121.38.22*")
        {
        $mapaddress = $mapitem.Substring($mapitem.indexof("\"), (($mapitem.Lastindexof("\")) - ($mapitem.indexof("\")) )) # 
        $mapitem =  $mapitem.trim()
        net use /delete $mapaddress
        }
}


net use R: \\10.121.38.22\Documentation (Find-PasswordInKeePassDB -EntryToFind "rha") /user:rha

KeeGrouptoXML -PathToDB "R:\Keypass\SFTPAccounts.kdbx" -GroupToSearch "Hermes" -PasswordToDB (Find-PasswordInKeePassDB) -OutputFile $outfile

net use /delete R: