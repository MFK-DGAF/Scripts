#  This script gets the all the patient with duplicate service code
#  and create a skinny's for specific hospital code.
cls
$SQLServer = “10.73.239.110”
$SQLDBName = “CPROCS”
$SqlQuery = ‘EXEC [dbo].[usp_DuplicateServiceCode]’
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

# populate all patient id into the temp table
foreach ($row in $DataSet.Tables[0].Rows)
{
    $facilityid = $row[0].ToString().Trim()
    $actualpatientid = $row[1].ToString().Trim()
    $patientlast = $row[2].ToString().Trim()
    $servicecode = $row[3].ToString().Trim()
    if ($actualpatientid -match "Patient"){}
	else {
		if ($hashpatientid.ContainsKey($actualpatientid)){}
		else {
			$counter += 1
			$hashpatientid.Add($actualpatientid,$facilityid)
		}
		
		if ($facilitytbl.ContainsKey($facilityid)) {}
		else {
		    $facilitycount+=1
			$facilitytbl.Add($facilityid, $facilitycount)
		}
	}
}

# $hashpatientid
# $facilitytbl
# $jj = $hashpatientid.Get_Item("741258")
# write-host $jj '..........'
# EXIT
# loop into facility table by the facility code, then read the configuration file to
# pick up the file name base on the configuration file.  
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
    
    #  get files from listfiles and populate into temp "hashtable"

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

    #-- create supper skinny file from the given list
    foreach ($filekey in $hashtable.keys) {
	    #open a file for reading
        $ifile = $c_DirPath+'\'+$filekey
	    $Infile = [system.io.file]::OpenText($ifile)
	    $rec = ''                # initialized variable
        $iFilename = $filekey.split(".") 
        $Filename_1 = $iFilename[0] # file name
        $Filename_2 = $iFilename[1] # extension
        
		# new file name for the supper skinny files
        $newFilename = $c_outfiledir + $Filename_1 + '_reload.' + $Filename_2

	    #create header record
	    $rec = $Infile.ReadLine()
	    Add-Content $newFilename $rec
        $valnum = 2
	    if ($filekey -match "REVCPT") {$valnum = 1}
	    # loop to all files and find a matches for patient id to
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
				# the given hospital code should be the same as the hashpatientid temp table.
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
