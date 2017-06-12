$computer = "wg0501kp"
$ComputerListSource = "C:\Users\tspooner\Documents\WorkSpace_VisioAudit\visio_hosts.txt"
$outfile = "C:\Users\tspooner\Documents\WorkSpace_VisioAudit\visio_audit_out.txt"
$computerList = Get-Content $ComputerListSource
foreach ($computer in $computerlist)
{
	write-output $computer >> $outfile 
	if (test-Connection -ComputerName $computer -Count 2 -Quiet) 
	{
	gwmi win32_softwareFeature -computername $computer | select-object productname, lastuse -unique | where {$_.productname -like "*Visio Pro*"} >> $outfile
	}
	else
	{
	write-output "the computer did not respond to ping, try it later" >> $outfile
	}
}

