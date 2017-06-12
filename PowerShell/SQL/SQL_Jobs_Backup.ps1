[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
$serverInstance = "."

$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance

foreach ($job in $server.JobServer.Jobs)
{
    $jobname = "C:\temp\test\file_" + $job.name.ToString() + "_job.sql"
    
    $script = $job.Script()
    print $script > $jobname

}

