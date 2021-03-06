#-----------------------------------------------------------------------------------------
# Ramon Tupas | 07/07/2014 | Rush-Health
# This script will extract and create files because of patient have duplicate service code
# found during the import into pmmc
#-----------------------------------------------------------------------------------------
cls
# Set-ExecutePolicy RemoteSigned -Scope CurrentUser
$arrayPatid = Get-Content("C:\PSHELL\PatientId.txt")

$listFiles = get-childitem("E:\PMMC Contract Pro\ptemp\*.csv")
foreach($file in $listFiles)
{
  #get filename from file directory
  $filename = split-path $file -leaf -resolve
  $iFilename = $filename.split(".") 
  $Filename_1 = $iFilename[0] # filename
  $Filename_2 = $iFilename[1] # extension
  $DirPath = split-path $file
  
  #create new file name 
  $newFilename = $DirPath + '\extractfiles\' + $Filename_1 + '_1.' + $Filename_2
  if ($Filename_1.contains('PAYER_') -Or $Filename_1.contains('VOID_'))
  {
     $msgstr = $Filename_1 + ' - not included in the search!'
	 Write-Host($msgstr)
  }
  else
  {
	#open a file for reading
	$Infile = [system.io.file]::OpenText($file)
	$rec = ''                # initialized variable

	#create header record
	$rec = $Infile.ReadLine()
	Add-Content $newFilename $rec
  
	# loop to all files and find a match for patient id to
	# create detail records
	
	$counter = 0
	While (!($Infile.EndOfStream)) {
		$rec = ''
		$rec = $Infile.ReadLine()
		$recSplit = $rec.split(",") 
		$patidstr =($recSplit[2].Replace('"',""))
		if ($arrayPatid -contains $patidstr)
		{
			Add-Content $newFilename $rec
			Write-Host($patidstr)
			$counter += 1
		}
	}
	$Infile.close()

	# no detail record, detail the filename 
	if ($counter -eq 0)
	{
		Remove-Item $newFilename
	}	
  }
}