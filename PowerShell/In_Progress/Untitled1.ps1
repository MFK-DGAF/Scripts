[string]$FullJob="MAINTENANCE[_]BackupWeekly.Backup and Cleanup"
[string]$IncJob="MAINTENANCE_BackupDaily.Incremental Backups"
$ExceptionList
[string]$outputDir=""
[int]$FullDistance = -7
[int]$IncDistance = -4

import-module sqlps

$SQL_Job_Query=@"
SELECT
    [sJOB].[name] AS [JobName], 
	[sJSTP].[command] AS [ExecutableCommand]
FROM
    [msdb].[dbo].[sysjobsteps] AS [sJSTP]
    INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB]
        ON [sJSTP].[job_id] = [sJOB].[job_id]
    where [sJOB].[name] like `$(JobName)
ORDER BY [JobName]
"@


$SQL_Maintenance_Plan_Query =@"
select CAST(CAST([packagedata] as varbinary(max)) as xml) 
from msdb.dbo.sysssispackages
where name like `$(PlanName)
"@

$Job_Lookup_Param = "JobName='%" + $FullJob + "%'"
$JobInfo = (invoke-sqlcmd -ServerInstance "localhost" -database "master" -Query $SQL_Job_Query -Variable $Job_Lookup_Param).ExecutableCommand
$Maintenance_Plan_Temp = $Jobinfo.split("/") | where {$_ -like "*Maintenance Plans\*" } 
$Maintenance_Plan_Name = $Maintenance_Plan_Temp -split "\\" | where {$_ -notlike "*Maintenance Plans*"}
$Maintenance_Plan_Name = $Maintenance_Plan_Name.replace('"', "")
$Maintenance_Plan_Name = $Maintenance_Plan_Name.Trim()

$Maint_Plan_Param = "PlanName='%" + $Maintenance_Plan_Name + "%'"
$Maint_Plan_col1 = (invoke-sqlcmd -ServerInstance "localhost" -Database "master" -Query $SQL_Maintenance_Plan_Query -Variable $Maint_Plan_Param  -MaxCharLength 32000).column1

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
        [string]$SystemDB_output+= get-childitem ($BackupDir + "\" + $BackupChild + "\*.bak") | where {$_.LastWritetime -gt (Get-Date).AddDays($FullDistance)} 
    }
    else 
    {
        [string]$UserDB_output+= get-childitem ($BackupDir + "\" + $BackupChild + "\*.bak") | where {$_.LastWritetime -gt (Get-Date).AddDays($FullDistance)}
    }
}
