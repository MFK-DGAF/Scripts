param(

    $PathToKeePassFolder = "C:\Program Files (x86)\KeePass Password Safe 2"
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

<#Function Find-PasswordInKeePassDB
{
    [CmdletBinding()]
    [OutputType([String[]])]

    param(

        $PathToDB = "C:\Powershell\PowerShell.kdbx",
        $EntryToFind = "MasterPassword"
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

}#>

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
   FindPasswordInKeePassDBUsingPassword -EntryToFind "domain\username" -PasswordToDB myNonTopSeceretPasswordInClearText
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
        $OutputFile = "C:\Users\Tspooner\Desktop\OutFile.xml",
        # Password used to open KeePass DB        
        [Parameter(Mandatory=$true)][String]$PasswordToDB
    )

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
        <#if ($pwItem.Strings.ReadSafe("Title") -eq $EntryToFind)
        {
            $pwItem.Strings.ReadSafe("Password")
        }#>
        if ($pwItem.ParentGroup.Name -eq "Hermes")

    }
    $PwDatabase.Close()
    $PasswordToDB = $null

}

