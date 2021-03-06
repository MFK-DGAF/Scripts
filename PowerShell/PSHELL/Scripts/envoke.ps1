cls
$code = read-host -prompt 'Enter hosp code "RUMC, OAK, CMC, RMC"'
$varsfile = 'C:\PSHELL\FILECONFIG\PMMC_'+$code+'.txt'
$recs = get-content $varsfile
$array_recs = $recs[0]
$array_recs = $recs[0].split(']')
$hosp_code = $array_recs[0]
$DirPath  = $array_recs[1]
$patientlistfile = $array_recs[3]
$notepadedit = $array_recs[3]

$hashfiles=$null
$hashfiles=@{}
$filecount = (Get-ChildItem $DirPath).count
$listfiles = Get-ChildItem $DirPath -name
foreach ($file in $listfiles){
    if ($hashfiles.containsKey($file)){
       # I have the file already!   
    }
    else {
        for($i=1; $i -le $filescount; $i++){
            $atrec = $recs[$i].split(']')
            $c_file = $atrec[0]
            $c_detlcount = $atrec[1]
            if ($file | select-string -pattern $c_file) {
                 $num = $c_detlcount
                 break
            }
         }
         $hashTable.Add($file,$i)
     }
}

exit
Invoke-Item $notepadedit


$arrayPatid = Get-Content($patientlistfile)
$listfiles = Get-ChildItem $DirPath -name 
foreach($file in $listFiles)
{
  #get filename from file directory
  $filename = split-path $file -leaf -resolve
  $iFilename = $filename.split(".") 
  $Filename_1 = $iFilename[0] # filename
  $Filename_2 = $iFilename[1] # extension
  $DirPath = split-path $file
  
  #create new file name 
  $newFilename = $DirPath + '\extractfiles\' + $Filename_1 + '_reload.' + $Filename_2
  if ($Filename_1.contains('PAYER_') -Or $Filename_1.contains('VOID_'))
  {
     $msgstr = $Filename_1 + ' - not included in the search!'
	 Write-Host($msgstr)
  }
  else
  {
	$Infile = [system.io.file]::OpenText($file)
	$rec = ''                

	$rec = $Infile.ReadLine()
	Add-Content $newFilename $rec
    $valnum = 2
	if ($file -match "REVCPT") {$valnum = 1}
	
	$counter = 0
	While (!($Infile.EndOfStream)) {
		$rec = ''
		$rec = $Infile.ReadLine()
		$recSplit = $rec.split(",") 
		$patidstr =($recSplit[$valnum].Replace('"',""))
		if ($arrayPatid -contains $patidstr)
		{
			Add-Content $newFilename $rec
			Write-Host($patidstr)
			$counter += 1
		}
	}
	$Infile.close()

	if ($counter -eq 0)
	{
		Remove-Item $newFilename
	}	
  }
}