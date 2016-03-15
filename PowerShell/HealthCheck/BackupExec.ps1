import-module BEMCli

$MostRecentIncremental = Get-BEJobhistory -Name "*Incremental" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1

switch ($MostRecentIncremental.JobStatus)
{
"Succeeded"
	{
	if ((Get-Date).AddDays(-4) -le $MostRecentIncremental.StartTime)
		{
			$LastGoodIncremental = $MostRecentIncremental
			$JobStatus = "[OK]"
		}
		elseif ((Get-Date).AddDays(-6) -le $MostRecentIncremental.StartTime)
		{ 
			$LastGoodIncremental = $MostRecentIncremental
			$JobStatus = "[Warning: Age]"
		}
		else
		{
			$LastGoodIncremental = $MostRecentIncremental
			$JobStatus = "[NOT RUNNING]"
		}
	}
"SucceededwithExceptions"
	{
	if ((Get-Date).AddDays(-5) -le $MostRecentIncremental.StartTime)
		{
			$LastGoodIncremental = $MostRecenIncremental
			$JobStatus = "[Warning: Exceptions]"
		}
	else 
		{ 
			$BadJob = $MostRecentIncremental
			$JobStatus = "[NOT RUNNING]"
		}
	}
"Failed"
	{
	$LastGoodIncremental = Get-BEJobhistory -Name "*Incremental" -JobStatus "Succeeded" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		if ($LastGoodIncremental -eq $EmptyString)
		{
			$LastGoodIncremental = Get-BEJobhistory -Name "*Incremental" -JobStatus "Succeededwithexceptions" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		}
		$BadJob = $MostRecentIncremental
		$JobStatus = "[FAILED]"
	}

default
	{
	$JobStatus = "[NOT RUNNING]"
	$LastGoodIncremental = Get-BEJobhistory -Name "*Incremental" -JobStatus "Succeeded" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		if ($LastGoodIncremental -eq $EmptyString)
		{
			$LastGoodIncremental = Get-BEJobhistory -Name "*Incremental" -JobStatus "Succeededwithexceptions" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		}
	}


}

Write-Output "Backup Exec Incremental" ("Status:          " + $JobStatus) ("`tLast Successful Backup: " + $LastGoodIncremental.StartTime + "`t") > F:\BackupAudit\BUE-PHOSQL03.txt


$MostRecent = Get-BEJobhistory -Name "*Full" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1

if((Get-Date).AddDays(-8) -le $MostRecent.StartTime)
	{
	if ($MostRecent.JobStatus -like "Succeeded*")
		{ 
		$LastGood = $MostRecent
		$JobStatus = "[OK]"
		}
	else
		{ 
		$LastGood = Get-BEJobhistory -Name "*Full" -JobStatus "Succeeded" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		if ($LastGood -eq $EmptyString)
		{
		$LastGood = Get-BEJobhistory -Name "*Full" -JobStatus "Succeededwithexceptions" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		}
		$BadJob = $MostRecent
		$JobStatus = "[FAILED]"
		}
	}
Else
{
$JobStatus = "[NOT RUNNING]"
$LastGood = Get-BEJobhistory -Name "*Full" -JobStatus "Succeeded" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
if ($LastGood -eq $EmptyString)
		{
		$LastGood = Get-BEJobhistory -Name "*Full" -JobStatus "Succeededwithexceptions" | Sort-Object -Property "StartTime" -Descending | Select-Object -First 1
		}
}

Write-Output "Backup Exec Full" ("Status:          " + $JobStatus) ("`tLast Successful Backup: " + $LastGood.StartTime + "`t") >> F:\BackupAudit\BUE-PHOSQL03.txt