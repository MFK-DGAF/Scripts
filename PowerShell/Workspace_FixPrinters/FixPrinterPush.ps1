$SourceDir = "C:\Users\tspooner\Documents\Workspace_FixPrinters\"
$SourceFile = "C:\Users\tspooner\Documents\Workspace_FixPrinters\FixPrinters.bat"
$HostList = Get-Content "C:\Users\tspooner\Documents\Workspace_FixPrinters\HostList.txt"


ForEach ($Server in $HostList) 
{
#check if server is alive
	if (test-Connection -ComputerName $Server -Count 2 -Quiet) 
		{
		$DestDir = write-output ("\\" + $Server + "\c$\Windows\")
		copy-item $SourceFile $DestDir -force
		}
	else
		{
		$outfile = write-output ($sourceDir + "BadHosts.txt")
		write-output ("The host " + $Server + " did not respond to ping and did not recieve the updates to the signature file") >> $outfile
		}

}

