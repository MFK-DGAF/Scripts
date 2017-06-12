param(
    [string]$ServerList ="E:\automation\SQLServerList.txt",
    [string]$NewFile = "E:\automation\deploy\newfile.txt", 
    [string]$JobName = "HealthCheck",
    [string]$StepName = "Disk",
    [string]$EmailAddress = "Torsten_Spooner@rush.edu", 
    [string]$EmailServer = "Cheech"
    )

. "GetBakDir"
. "SQL_Script_Functions"

$ExecutableName = "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe"

if (Test-Path $ServerList)
{
    $Servers_Array = Get-Content $ServerList
    foreach ($Server in $Servers_Array)
    {
        if (test-Connection -ComputerName $Server -Count 2 -Quiet)
        {
            $BakDir = GET_BAK_DIR $Server
            $ScriptDir = Get_Dir $Server $JobName "automation"
            $ScriptFileName = $NewFile.SubString(($NewFile.LastIndexOf("\")+1), ($NewFile.Length - ($NewFile.LastIndexOf("\")+1)))
            $ScriptName = write-output ($ScriptDir + "\" + $ScriptFileName)
            $LocalScriptName 

            #if script exists, rename with _date_archive and move to /archive folder (create if it does not exist) 
            #create archive function

            #copy over new file

            #get backup dir and output dir values
            $ScriptText = write-ouput ($ExecutableName + " " + $LocalScriptName + " " + $flags)

            $JobName = GET_JOB_NAME -Server $Server -JobName $JobName
            $StepNumber = GET_STEP_NUM -ServerName $Server -JobName $JobName -StepName = "Disk"
            
            UPDATE_JOB_CONTENTS $JobName $StepNumber $Value, $ServerName = $env:COMPUTERNAME

            $MigrateResults = MIGRATE_FILE -File $NewFile -DestDir $ScriptDir -ServerName $Server
        }
        else 
        {
            $emailText.add
        }
    }
}
else
{
$emailText = Write-Output ("The ServerList file: " + $ServerList + " cannot be found. The script update cannot be continuted")
} 
