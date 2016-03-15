# Creating skinny's if there are duplicate service code on the PMMC import
# after Robert or David delete those duplicate service code in the PMMC system.
CLS
$ext = '*.csv'
$code = read-host -prompt "Enter Facility (CMC, RPS, OAK1) code"
$varsfile = 'C:\PSHELL\FILECONFIG\PMMC_'+$code+'.txt'
$hashpatientid=$null
$hashpatientid=@{} 
$i=0
$wsh = new-object -comobject wscript.shell
do {
    $patientid = Read-Host "PatientId: "
    #and so on, and so on, end with this:
    $answer = $wsh.popup("Do you want to add more?", 0,"more patient id?",4) 
    If ($answer -eq 6) { 
            $continue = $True 
            
        } else { 
            $continue = $False 
        }
        $i+=1 
        $hashpatientid.Add($patientid,$i)
} while ($continue -eq $True)
$hashpatientid
exit
$recs = get-content $varsfile
$array_recs = $recs[0].split(']')
$c_runtimedir= $array_recs[1]
$listfiles = Get-ChildItem $c_runtimedir -name -filter $ext
$lines = $recs.count
$hashfiles=$null
$hashfiles=@{}  # empty table

For ( $i = 1; $i -le $lines; $i+=1 ) { 
    if ($recs[$i] -ne $null){
        $hashfiles.add($recs[$i],'999')
    }
}

foreach($file in $listFiles) {
    $a = $file.length
    foreach ($h in $hashfiles.Keys) {
        #Write-Host "${h}: $($hashfiles.Item($h[0]))"
        #write-host $hashfiles.item($h)
        $b = $h.length
        $c = $a - $b
        if ($file.substring($c,$b) -eq $h){
         #write-host '------------' $file
        } else{
           write-host $file $h
        }
       

    }  
}

exit

$SQLServer = “servername”
$SQLDBName = “database”
#$SqlQuery = ‘EXEC [dbo].[usp_mystoredprocedure] ’ + $parameter1 + "’, ”’ + $parameter2 + ””
$SqlQuery = ‘EXEC [dbo].[usp_mystoredprocedure]’
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

foreach ($row in $DataSet.Tables[0].Rows)
{
    $Drive = $row[1].ToString().Trim()
    $Threshold = $row[2].ToString()
    $MountPoint = $row[3].ToString().Trim()
 #  add record on the the patientid.txt
}

$arrayPatientid = Get-Content("C:\PSHELL\PatientId.txt")




