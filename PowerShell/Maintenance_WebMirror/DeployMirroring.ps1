$dbListFile = "e:\automation\Maintenance_WebMirror\WebMirrorConfiguration.csv"
$sourceServer = "ginger"
$mirrorServer = "maryann"
$witnessServer = "chong,50839"

. "E:\automation\Maintenance_WebMirror\Mirror_Functions.ps1"

#$dbList = import-csv -Path $dbListFile
$dbList = "RHA_Staging"
$sourceDirectory = write-output ("SQLSERVER:\SQL\" + $sourceServer + "\DEFAULT\DATABASES")
$mirrorDirectory = write-output ("SQLSERVER:\SQL\" + $mirrorServer + "\DEFAULT\DATABASES")

foreach ($MirrorDB in $dbList)
{
    
    if (($MirrorDB.Database -ne $null) -and ($MirrorDB.Database -ne ""))
    {
        $Databaseinfo = dir $sourceDirectory | select * | Where {$_.Name -eq  $MirrorDb.Database}
        if ($Databaseinfo -eq $null)
        {
            write-output "This database does not exist"
        }
        else 
        {
            write-output ("The database " + $Databaseinfo.Name  + " has a mirroring status of " + $Databaseinfo.MirroringStatus + " and a witness status of " + $Databaseinfo.MirroringWitnessStatus)
        }
      
    }
    else
    {
    write-output $MirrorDB
    write-output $dbListFile
    write-output $dbList
    }

    #check if db exists in source
    #backup full db
    #trasnfer
    #make db
    #restore full
    #backup log
    #transfer
    #restore log
    #create mirror endpoints
    #associate mirror endpoints
    #check if mirroring, has secondary, has witness
    #output result





}

