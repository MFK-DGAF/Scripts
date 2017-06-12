$RushLogoSource1=@"
width:161.25pt; height:25.5pt
"@
$RushLogoDest1=@"
width:161.25pt; height:25.65pt
"@
$RushLogoSource2=@"
width=215 height=34
"@
$RushLogoDest2=@"
width=200 height=34
"@
$MailLogoSource1=@"
style='width:28.5pt;height:27.75pt
"@
$MailLogoDest1=@" 
style='width:25.6pt;height:25.65pt
"@
$MailLogoSource2=@"
width=38 height=37
"@
$MailLogoDest2=@"
width=34 height=34
"@
$LinkedInSource1=@"
width:28.5pt;height:28.5pt
"@
$LinkedInDest1=@"
width:33.88pt;height:25.6pt
"@
$LinkedInSource2=@"
width=38 height=38
"@
$LinkedInDest2=@"
width=45 height=34
"@
$ConfidentSource1=@"
color:black;mso-themecolor:text1;font-size:8.0pt;'>CONFIDENTIALITY
"@

$ConfidentDest1=@"
font-size:8.0pt;font-family:"Arial";'>CONFIDENTIALITY
"@

$ConfidentSource2=@"
prohibited. </span></a></span><span class=MsoHyperlink><span
style='color:black;mso-themecolor:text1'><o:p></o:p></span></span></p>
"@

$ConfidentDest2=@"
prohibited. </span></a></p>
"@


$imageSourceDir = "C:\Users\tspooner\Documents\Workspace_Signatures\images\*.jpg"
$ServerList = Get-Content "C:\Users\tspooner\Documents\Workspace_Signatures\images\Serverlist.txt"
$sourceDir = "C:\Users\tspooner\Documents\Workspace_Signatures\images\"

ForEach ($Server in $ServerList) 
{
#check if server is alive
	if (test-Connection -ComputerName $Server -Count 2 -Quiet) 
		{
		$dirstring = write-output ("\\" + $Server + "\c$\Users\")
		$userList = get-childitem $dirstring
		foreach ($user in $userList)
		{
			$SigDir = write-output ($dirstring + $user.Name + "\AppData\Roaming\Microsoft\Signatures\")
			if (Test-Path $SigDir)
			{
				$SigWild = write-output ($SigDir + $user.Name + "-*.htm")
				$SigDirWild = write-output ($SigDir + $user.Name + "-*_files")
				$SigDirList = get-childitem $SigDirWild
				$SigList = get-childitem $SigWild
				foreach ($sigfile in $SigList)
				{
                    if ($sigfile -ne $null)
					{
                    $SigFileData = Get-Content $sigfile.Fullname
					$SigFileData = $SigFileData -replace $RushLogoSource1, $RushLogoDest1
					$SigFileData = $SigFileData -replace $RushLogoSource2, $RushLogoDest2
					$SigFileData = $SigFileData -replace $MailLogoSource1, $MailLogoDest1
					$SigFileData = $SigFileData -replace $MailLogoSource2, $MailLogoDest2
					$SigFileData = $SigFileData -replace $LinkedInSource1, $LinkedInDest1
					$SigFileData = $SigFileData -replace $LinkedInSource2, $LinkedInDest2
					$SigFileData = $SigFileData -replace $ConfidentSource1, $ConfidentDest1
					$SigFileData = $SigFileData -replace $ConfidentSource2, $ConfidentDest2
					$SigFileData | Set-Content  $sigfile.Fullname -force
                    }
                }
				foreach ($SigFileDir in $SigDirList)
				{
					#$image1dest = write-output ($SigFileDir.Fullname + "\image001.jpg")
					#$image2dest = write-output ($SigFileDir.Fullname + "\image002.jpg")
					#$image3dest = write-output ($SigFileDir.Fullname + "\image003.jpg")
					copy-item $imageSourceDir $SigFileDir -force
				
				}
			}
		}
		}
		else
		{
		$outfile = write-output ($sourceDir + "failt.txt")
		write-output ("The host " + $Server + " did not respond to ping and did not recieve the updates to the signature file") >> $outfile
		}

}

