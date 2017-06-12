$computer = "wg0501kp"
$ComputerListSource = "C:\Users\tspooner\Documents\WorkSpace_VisioAudit\visio_hosts.txt"
$outfile = "C:\Users\tspooner\Documents\WorkSpace_VisioAudit\visio_audit_out.txt"
$computerList = Get-Content $ComputerListSource
foreach ($computer in $computerlist)
{
	#write-output $computer >> $outfile 
	if (test-Connection -ComputerName $computer -Count 2 -Quiet) 
	{
		$pcvisiolist = gwmi win32_softwareFeature -computername $computer | select-object productname, lastuse -unique | where {$_.productname -like "*Visio Pro*"} | where {$_.lastuse -like "20*"}
		
		$MaxDate = 0
		$ProgramName = ""
		$visiolinecount = 0
		foreach ($visioline in $pcvisiolist)
		{
			if ($visiolinecount -eq 0)
			{
				$MaxDate = $visioline.lastuse
				$ProgramName = $visioline.productname
			}
			else
			{
				if ($MaxDate -lt $visioline.lastuse)
				{
					$MaxDate = $visioline.lastuse
					$ProgramName = $visioline.productname
				}
			}
			$visiolinecount++
		}
        #$PrettyMaxDate = [datetime]::ParseExact($MaxDate.Substring(0,8),'yyyyMMdd', $null)
		#write-output ($ProgramName + "        " + $MaxDate.Substring(0,8)) >> $outfile
        write-output ($Computer + "        " + $MaxDate.Substring(0,8)) >> $outfile
	}
	else
	{
	write-output "the computer did not respond to ping, try it later" >> $outfile
	}
}

