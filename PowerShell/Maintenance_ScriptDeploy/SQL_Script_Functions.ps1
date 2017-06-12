function GET_JOB_NAME ([string]$ServerName = $env:COMPUTERNAME, [string]$JobName = "HealthCheck")
{
import-module sqlps -DisableNameChecking

$QueryString = "select name FROM Msdb.dbo.SysJobs where name like `$(JobName)"
$Job_Param = "JobName='%" + $JobName + "%'"

$Job = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $QueryString -Variable $Job_Param

return $Job.name
}



function GET_STEP_NUM ([string]$ServerName = $env:COMPUTERNAME, [string]$JobName = "HealthCheck", [string]$StepName = "Disk")
{
    import-module sqlps -DisableNameChecking

$QueryString = 
@"
SELECT JOB.NAME AS JOB_NAME,
STEP.STEP_ID AS STEP_NUMBER,
STEP.STEP_NAME AS STEP_NAME,
STEP.COMMAND AS STEP_QUERY,
DATABASE_NAME, STEP.subsystem
FROM Msdb.dbo.SysJobs JOB
INNER JOIN Msdb.dbo.SysJobSteps STEP ON STEP.Job_Id = JOB.Job_Id
WHERE JOB.Enabled = 1
AND (JOB.Name LIKE `$(JobName) AND STEP.STEP_Name LIKE `$(StepName))
ORDER BY JOB.NAME, STEP.STEP_ID
"@


    $Name_Param = "JobName='%" + $JobName + "%'"
    $Step_Param = "StepName='%" + $StepName + "%'"
    $Job_Param = $Name_Param, $Step_Param

    $JobStep = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $QueryString -Variable $Job_Param

    if (($JobStep.STEP_NUMBER -eq $null) -or ($JobStep.STEP_NUMBER -eq ""))
    {
        $output = 0
    }
    else
    {
        $output = $JobSTep.STEP_NUMBER
    }
    
    return $output 
}

function UPDATE_JOB_CONTENTS ([string]$JobName, [int]$StepNumber, [string]$Value, [string]$ServerName = $env:COMPUTERNAME)
{

$Update_JOB_Query= 
@"
EXEC msdb.dbo.sp_update_jobstep @job_Name=N`$(JobName), @step_id=`$(StepNumber) , 
		@command=N`$(JobContents)
"@

    $JobName_Param = "JobName='" + $JobName + "'"
    $JobStep_Param = "StepNumber=" + $StepNumber
    $JobContent_Param = "JobContents='" + $Value + "'"
    $Job_Params = $JobName_Param, $JobStep_Param, $JobContent_Param


    $Results = invoke-sqlcmd -ServerInstance $ServerName -Database "msdb" -Query $Update_JOB_Query -Variable $Job_Params

}



