param(#
    [string]$DBName, 
    [string]$SourceServer,
    [string]$DestServer,
    [string]$DBTempDir,
    [string]$AuditScriptDir = "E:\automation\SQLPermissions",
    [string]$AuditDBName = "RHA_AUDIT", 
    [string]$AuditDBServer = $env:COMPUTERNAME,
    [int]$BatchNumber
)

. "E:\automation\Maintenance_DBCut\Mirror_Functions.ps1"

function GET_MAX_Batch_No(
    [string]$DBName, 
    [string]$Server, 
    [string]$AuditDBName
)
{
$runDir = (Get-Location).Path
##########################################################################################
# import SQL module
##########################################################################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir

$SQLCMD = @"
select MAX(BatchNumber) from rha_dbPermissions.UserPermissions where Database_Name = `$(DBNAMEN)
"@

$param = "DBNAMEN='" + $Batch_num + "'"

$Val = Invoke-Sqlcmd -Query $SQLCMD -Variable $param -ServerInstance $Server -Database $AuditDBName

return $Val.BatchNumber

}

$StoreRightsPath = write-output ($AuditScriptDir + "\SQLPermissions_Store.ps1")
$ApplyRightsPath = write-output ($AuditScriptDir + "\SQLPermissions_Apply.ps1")

$Arguments = $AuditDBServer, $DBName, $AuditDBName
Invoke-Expression  "$StoreRightsPath $Arguments"

MigrateDB $DBName $SourceServer $DestServer $DBTempDir

if (!($BatchNumber))
{
   $BatchNumber = GET_MAX_Batch_No $DBName $AuditDBServer $AuditDBName
}

$Arguments = $DestServer, $DBName, $AuditDBName, $AuditDBServer, $BatchNumber
Invoke-Expression  "$ApplyRightsPath $Arguments"