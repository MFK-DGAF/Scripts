[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null
$serverInstance = "."

$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance

foreach ($job in $server.JobServer.Jobs)
{
    $jobname = "G:\Backups\SQL Server Agent Jobs\" + $job.name.ToString() + ".sql"
    
    $script = $job.Script()
    print $script > $jobname

}

Pause