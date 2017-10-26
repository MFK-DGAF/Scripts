#SQLTask:BackupDestinationAutoFolderPath="G:\Backups" 
$FullJob="BackupWeekly"
$Servername = "phosql03"

##########################################
# import SQL module
##########################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    $runDir = (Get-Location).Path
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
     cd $runDir           
}

#query to pull xml definition of maintenance plan
$SQL_Maintenance_Plan_Query =@"
select CAST(CAST([packagedata] as varbinary(max)) as xml) 
from msdb.dbo.sysssispackages
where name like `$(JobName)
"@

$Maint_Plan_Param = "JobName='" + $FullJob + "'"
$Maint_Plan_col1 = (invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Maintenance_Plan_Query -Variable $Maint_Plan_Param  -MaxCharLength 32000).column1

#Split apart maintenance plan info and find line where SQL backup dir is defined
$Val = $Maint_Plan_col1.Split(" ") | where {$_ -like "*SQLTask:BackupDestinationAutoFolderPath*"}
$ValEquals = $Val.IndexOf("=") + 1
$BackupDir = ($val.Substring($ValEquals, $val.Length - $ValEquals)).replace('"',"")

$BackupParent = get-childitem $BackupDir
#get list of file contents for each 

foreach ($BackupChild in $BackupParent.name) 
{ 
    if ($BackupChild -in ("master", "model", "msdb"))
    {
        write-output $x
        [string]$SystemDB_output+= get-childitem ($BackupDir + "\" + $BackupChild + "\*.bak") | where {$_.LastWritetime -gt (Get-Date).AddDays(-7)} 
    }
    else 
    {
        write-output $x
        [string]$UserDB_output+= get-childitem ($BackupDir + "\" + $BackupChild + "\*.bak") | where {$_.LastWritetime -gt (Get-Date).AddDays(-7)}
    }
}