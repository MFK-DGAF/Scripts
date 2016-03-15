cls
$SQLServer = “PHOSQL03”
$SQLDBName = “RHA_UTILITY”
#$SqlQuery = ‘EXEC [dbo].[usp_samplequery]’
$SqlQuery = 'select * from [dbo].[powershelltest] order by facilityid, actualpatientid'
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = “Server=$SQLServer;Database=$SQLDBName;Integrated Security=True”
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close()

$facilitytbl = $null
$facilitytbl = @{}

$hashpatientid=$null
$hashpatientid=@{} 

$facilitycount = 0
$counter = 0

foreach ($row in $DataSet.Tables[0].Rows)
{
    $facilityid = $row[0].ToString().Trim()
    $actualpatientid = $row[1].ToString().Trim()
    $patientlast = $row[2].ToString().Trim()
    $servicecode = $row[3].ToString().Trim()

    if ($hashpatientid.ContainsKey($actualpatientid)){}
    else {
        $counter += 1
        $hashpatientid.Add($actualpatientid,$facilityid)
    }
    
    if ($facilitytbl.ContainsKey($facilityid)) {}
    else {
        $facilitytbl.Add($facilityid, $facilitycount)
        $facilitycount+=1
    }
}

#$hashpatientid
#$facilitytbl

#$jj = $hashpatientid.Get_Item("741258")

#write-host $jj '..........'


foreach ($hkey in $facilitytbl.keys) {
    #write-host $hkey
    $varsfile = 'C:\PSHELL\FILECONFIG\PMMC_'+$hkey+'.txt'
    $recs = get-content $varsfile 
    $array_recs  = $recs[0].split(']')
    $c_faccode   = $array_recs[0]
    $c_DirPath   = $array_recs[1]
    $c_fileext   = $array_recs[2]
    $c_outfiledir= $array_recs[3]
    $c_numlines  = $recs.Count - 1
    $listfiles = Get-ChildItem $c_DirPath $c_fileext -NAME

    $hashtable = $null
    $hashtable = @{}
    
    #  get files from listfiles.

    foreach($file in $listFiles) {
        $file_string=$file.split('_')
        #write-host $file_string
        if ($hashTable.ContainsKey($file)){
            #  table has it.
        }
        else {
            for($i=1; $i -le $c_numlines; $i++){
                #Write-Host $i
                $specs_recs = $recs[$i].split(']')
                #write-host $specs_recs
                if ($specs_recs[0] -eq $file_string[0]) {
                    if ($specs_recs[1] -eq $file_string[10]) {
                        $hashTable.Add($file,$i)
                        break
                    }
                }
            }
        }
    }

    #$hashtable
    #EXIT

    #-- create supper skinny's file
    foreach ($filekey in $hashtable.keys) {
	    #open a file for reading
        $ifile = $c_DirPath+'\'+$filekey
	    $Infile = [system.io.file]::OpenText($ifile)
	    $rec = ''                # initialized variable
        $iFilename = $filekey.split(".") 
        $Filename_1 = $iFilename[0] # filename
        $Filename_2 = $iFilename[1] # extension

        $newFilename = $c_outfiledir + $Filename_1 + '_reload.' + $Filename_2

	    #create header record
	    $rec = $Infile.ReadLine()
	    Add-Content $newFilename $rec
        $valnum = 2
	    if ($filekey -match "REVCPT") {$valnum = 1}
	    # loop to all files and find a match for patient id to
	    # create detail records
	
	    $counter = 0
	    While (!($Infile.EndOfStream)) {
		    $rec = ''
		    $rec = $Infile.ReadLine()
		    $recSplit = $rec.split(",") 
		    $patidstr =($recSplit[$valnum].Replace('"',""))

            if ($hashpatientid.ContainsKey($patidstr))
		    {
                $jj = $hashpatientid.Get_Item($patidstr)
                #write-host $jj $c_faccode
                if ($c_faccode -eq $jj) {
			        Add-Content $newFilename $rec
			        Write-Host($patidstr)
			        $counter += 1
                }
		    }
	    }
	    $Infile.close()
    }
    #-- $states.Get_Item("Oregon")   .....$states.ContainsValue("Salem")
    # exit
}
