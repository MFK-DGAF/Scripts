param(
    [string]$NewFile = "E:\automation\deploy\newfile.txt", 
    [string]$JobName = "HealthCheck",
    [string]$StepName = "Disk",
    [string]$EmailAddress = "Torsten_Spooner@rush.edu", 
    [string]$EmailServer = "Cheech"
    )

. "E:\automation\Maintenance_ScriptManager\Get_Bak_Dir.ps1"
. "E:\automation\Maintenance_ScriptManager\SQL_Script_Functions.ps1"
. "E:\automation\Maintenance_ScriptManager\SQL_Query_Functions.ps1"
. "E:\automation\Maintenance_ScriptManager\Script_Functions.ps1"

$ExecutableName = "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe"


   

#        if (test-Connection -ComputerName $Server -Count 2 -Quiet)
#        {
#            $BakDir = GET_BAK_DIR $Server
#            $ScriptDir = Get_Dir $Server $JobName "automation"
#            $ScriptFileName = $NewFile.SubString(($NewFile.LastIndexOf("\")+1), ($NewFile.Length - ($NewFile.LastIndexOf("\")+1)))
#            $ScriptName = write-output ($ScriptDir + "\" + $ScriptFileName)
            

            #if script exists, rename with _date_archive and move to /archive folder (create if it does not exist) 
            #create archive function

            #copy over new file

            #get backup dir and output dir values
#            $ScriptText = write-ouput ($ExecutableName + " " + $LocalScriptName + " " + $flags)
#
#            $JobName = GET_JOB_NAME -Server $Server -JobName $JobName
#            $StepNumber = GET_STEP_NUM -ServerName $Server -JobName $JobName -StepName = "Disk"
#            
#            UPDATE_JOB_CONTENTS $JobName $StepNumber $Value, $ServerName = $env:COMPUTERNAME
#


function deploy_script 
(
    [string]$SourceServer = "phosql03", 
    [string]$sourceDir = "", 
    [string]$jobName = "Maintenance_HealthCheck", 
    [string]$scriptName
)
{
    $MasterList = new-object system.collections.arraylist
    
    ##Get Source File Hash####################################################
    
    if ($sourceDir -eq "")
    {
        $sourceDir = (Get-Item -Path ".\" -Verbose).FullName
    }
    
    $sourceFile = write-output ($sourceDir + "\" + $ScriptName)
    if ((test-path $sourceDir) -and (test-path $sourceFile))
    {
        
        $SourceServerInfo = GET_SERVER_INFO -servername $sourceServer
        $sourcePath = CONVERT_DRIVEPATH_TO_URL -DrivePath $sourceDir -ServerName $sourceServer
        $SourceMD5 = GET_HASH $SourcePath $ScriptName $sourceServer -RawPath
    }
    #########################################################################

    if ($sourceMD5 -ne 0)
    {
        $ServerList = GET_SERVER_LIST
        foreach ($Server in $ServerList)
        {
            $MigrateResults = ""
            $Hash = ""
            $scriptPath = CONVERT_DRIVEPATH_TO_URL -DrivePath $Server.ScriptDir -ServerName $Server.Name
            $cred = GET_DOMAIN_CRED_FROM_XML $Server.Domain
            $driveMapoutput = New-PSDrive -name T -PSProvider FileSystem -root $scriptPath -Credential $cred -Persist
            
            ###check if Parent dir exists
            if (Test-Path $scriptPath)
            {
                #if the script dir does not exist, make it
                $jobPath = write-output ($scriptPath + "\" + $JobName)
                if (!(Test-Path $jobPath))
                {
                    new-item -Path $jobPath -ItemType Directory
                    $MigrateResults += write-output ("The " + $jobPath + " directory was created on " + $Server.Name) 
                }
                
                #check if file exists, and compare MD5s.              
                $filepath = Write-Output ($scriptPath + "\" + $JobName + "\" + $ScriptName)
                if (Test-Path $filePath)
                {
                    $Hash = GET_Hash $JobName $ScriptName $Server.Name           
                }
                else 
                {
                    $Hash = 0
                }
                
                #if the files match, don't migrate anything. 
                if ($Hash -ne $SourceMD5)
                {
                    $MigrateResults += MIGRATE_FILE -File $sourceFile -DestDir $jobPath -ServerName $Server.Name -Domain $Server.Domain
                }
                else
                {
                    $MigrateResults += write-output ("The " + $ScriptName + " file on " + $Server.Name + " matches the copy on " + $sourceServer)
                }
                
            }
            else
            {
                $MigrateResuls += write-output ("The file migration did not complete for " + $Server.Name + " because the directory " + $scriptPath + " does not exist")
            }
            $removeinfo = Remove-PSDrive -name T
            $MasterList.Add($MigrateResuls)
            write-output $MigrateResults
          
        }
        $reportText = $MasterList | Out-String
        
    }
    else 
    {
        $reportText = "The Source file could not be found. Nothing was done"
    }
return $reportText
}

