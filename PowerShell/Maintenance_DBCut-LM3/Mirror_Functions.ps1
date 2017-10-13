function File_Exists (
    [string]$ServerName,
    [string]$Filename
)
{
$runDir = (Get-Location).Path
##########################################
# import SQL module
##########################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir
$query = @"
exec master.dbo.xp_fileexist `$(File)
"@



$File_Param = "File='" + $FileName + "'"


$output = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $query -Variable $File_Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue -QueryTimeout 2000

return $output.'File Exists'

}

function Remove_File_Broken (
    [string]$ServerName, 
    [string]$file
)
{
$runDir = (Get-Location).Path
##########################################
# import SQL module
##########################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}

cd $runDir
$query = "xp_cmdshell `$(file)"

$Out_Param = "file='del " + $outputString + "'"

invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $Query -Variable $Out_Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue -QueryTimeout 2000
}

function Backup_Database (
    [string]$DBName,
    [string]$BackDir,  
    [string]$ServerName, 
    [switch]$Mirror,
    [switch]$log
    )
{
$runDir = (Get-Location).Path
##########################################
# This function does a full or trans log 
# backup. It's designed to be used for 
# preparing DB's for mirroring
#
##########################################
# import SQL module
##########################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir
###########################################
# Define SQL Queries
###########################################
$full_Backup_Query = @"
BACKUP DATABASE [`$(DBNamen)] TO  DISK = N`$(OutputFile) WITH NOFORMAT, INIT,  NAME = N'DB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
"@

$log_Backup_Query = @"
BACKUP LOG [`$(DBNamen)] TO  DISK = N`$(OutputFile) WITH NOFORMAT, INIT,  NAME = N'DB-Transaction Log  Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
"@

###########################################
# Populate other variables
###########################################

$Date = get-date -format 'yyyyMMdd'

if ($Mirror)
{
    $MirrorText = "_Mirror"
}
else 
{
    $MirrorText = ""
}

if ($log)
{
    $outputString = write-output ($BackDir + "\" + $DBName + "_" + $Date + $MirrorText + ".trn")
    $BackupQuery = $log_Backup_Query
}
else
{
    $outputString = write-output ($BackDir + "\" + $DBName + "_" + $Date + $MirrorText + ".bak")
    $BackupQuery = $full_Backup_Query    
}


###########################################
# Execute the SQL
###########################################

$DBName_Param = "DBNamen=" + $DBName 
$Out_Param = "OutputFile='" + $outputString + "'"
$Param = $DBName_Param, $Out_Param

invoke-sqlcmd -ServerInstance $ServerName -Database $DBName -Query $BackupQuery -Variable $Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue -QueryTimeout 2000

###########################################
# Return backup file if successful 
# Return 0 if there was an error
###########################################

   # if ($sqlerr -eq $null)
   # {
   #     return $outputString
   # }
   # else
   # {
   #     return $sqlerr
   # }
   return $outputString
}

function Restore_Database (
    [string]$DBName, 
    [string]$ServerName, 
    [string]$BackupFile,
    [string]$instanceName = "Default",
    [switch]$recovery
    )
{
##########################################
# This is a function to restore
# Databases for mirroring
##########################################
$runDir = (Get-Location).Path
##########################################
# import SQL module
##########################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir
##########################################
# Get the status of the database
#########################################

 $SQLDir = write-output ("SQLServer:\SQL\" + $ServerName + "\" + $instanceName + "\Databases")
 $DBStatus = dir $SQLDir | SELECT Name, Status | Where {$_.Name -eq $DBName}


# E:\backups\RHA\RHA_backup_cut_2017_02_28.bak
###########################################
# Define SQL Queries
###########################################

if ($DBStatus.Status -like "Restoring")
{
$recovery_restore_query = @"
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1, NOUNLOAD,  REPLACE
GO
"@

$norecovery_restore_query = @"
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  REPLACE
GO
"@
}
else
{

$recovery_restore_query = @"
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1, NOUNLOAD,  REPLACE
GO
"@

$norecovery_restore_query = @"
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  REPLACE
GO
"@
}

if ($false)
{
#stored for archival purposes
$recovery_restore_query = @"
ALTER DATABASE [`$(DBNamer)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1, NOUNLOAD,  REPLACE
GO
"@

$norecovery_restore_query = @"
ALTER DATABASE [`$(DBNamer)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [`$(DBNamen)] FROM  DISK = N`$(BackupFile) WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  REPLACE
GO
"@
}

###########################################
# select the proper version of the query
# set the parameters and run the query
###########################################

if ($recovery)
{
$Query = $recovery_restore_query
}
else 
{
$Query = $norecovery_restore_query
}

$DBName1_Param = "DBNamer=" + $DBName
$DBName_Param = "DBNamen=" + $DBName 
$File_Param = "BackupFile='" + $BackupFile + "'"
$Param = $DBName1_Param, $DBName_Param, $File_Param

invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $Query -Variable $Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue -QueryTimeout 2000

    if ($SQLErr -eq $null)
    {
        return "Success!"
    }
    else 
    {
        return $SQLErr
    }

}

function Check_for_Mirror_Role (
    [string]$ServerName,
    [string]$role
)
{
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $Run
#SQL Query to test for endpoint
$SQL_Query_RoleTest=@"
select name from sys.database_mirroring_endpoints where role_desc = `$(Role)
"@
 
$Role_Param = "Role='" + $role + "'"
$DB = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query_RoleTest -Variable $Role_Param -ErrorAction SilentlyContinue 

return $DB.name

}

function Check_for_Endpoint_Port (
    [string]$ServerName, 
    [int]$PortNumber
)
{
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir
#SQL Query to test for endpoint
$SQL_Query_EndpointTest=@"
select name from sys.tcp_endpoints where type_desc = 'DATABASE_MIRRORING' and  port = `$(portnumber);
"@
 
$Port_Param = "PortNumber=" + $portnumber
$DB = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query_EndpointTest -Variable $Port_Param -ErrorAction SilentlyContinue 

return $DB.name

}

function Get_Endpoint_Port_By_Name (
    [string]$ServerName, 
    [string]$EndPointName
)
{
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir

$SQL_Query_EndpointTest=@"
select port from sys.tcp_endpoints where type_desc = 'DATABASE_MIRRORING' and Name = `$(EndpointName);
"@

$Name_Param = "EndpointName='" + $EndPointName + "'"
$DB = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query_EndpointTest -Variable $Name_Param -ErrorAction SilentlyContinue 

return $DB.port
}

function Get_DB_Mirror_Endpoints (
    [string]$ServerName
)
{
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir

$EndPoint_Query=@"
select name from sys.database_mirroring_endpoints
"@

$DB = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $EndPoint_Query -ErrorAction SilentlyContinue 

return $DB
}

function Remove_Mirror_Endpoints (
    [string]$ServerName
)
{
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir

$dropQuery=@"
drop endpoint `$(EndpointName)
"@

$endpointList = Get_DB_Mirror_Endpoints $ServerName

foreach ($endPoint in $endpointList)
{
    $EndPoint_Param = "EndpointName=" + $endPoint.name
    invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $dropQuery -Variable $EndPoint_Param -ErrorAction SilentlyContinue
}
}

function create_endpoint (
    [string]$ServerName, 
    [int]$portnumber,
    [string]$role
)
{
######################################################
# Creates the db mirroring endpoint if it does
# not already exist. Either way, it will return the 
# port number of the endpoint that DOES exist as the 
# return value. If an endpoint of a differnt type 
# already exists at that port, it will return 0
####################################################
$runDir = (Get-Location).Path
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
cd $runDir

#SQL Query to Create endpoint
$SQL_Query_Create= @"
CREATE ENDPOINT [`$(EndPointName)]
	STATE=STARTED
	AS TCP (LISTENER_PORT = `$(PortNum), LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = `$(role), AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM RC4)
"@

$existingEndpoint = Check_for_Mirror_Role $ServerName $role
$existingPort = Check_For_Endpoint_Port $ServerName $portnumber
 
if ($existingEndpoint)
{
    $outPutPort = Get_Endpoint_Port_By_Name $ServerName $existingEndpoint

    return $outputPort
}
else
{
    if ($existingPort)
    {
        return 0
    }
    else
    {
        $EndName = write-output ("Partner_" + $portnumber.ToString())
        $EndPointName_Param = "EndPointName=" + $EndName 
        $Port_Param = "PortNum=" + $portnumber
        $Role_Param = "role=" + $role
        $Param = $EndPointName_Param, $Port_Param, $Role_Param
        invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query_Create -Variable $Param -ErrorAction SilentlyContinue

        return $portnumber
    } 


}
}

function set_partner (
    [string]$DBName,
    [string]$ServerName,
    [string]$PartnerName, 
    [string]$portnumber 
)
{

$SQL_Query=@"
ALTER DATABASE `$(DataBaseName)
	SET PARTNER = `$(PartnerString)
GO
"@


if ($PartnerName.Contains(","))
{
    $PartnerName = $PartnerName.Substring(0,$PartnerName.IndexOf(","))
}

$DBName_Param = "DataBaseName=" + $DBName 
$Partner_Param = "PartnerString='TCP://" + $PartnerName + ":" + $portnumber + "'"
$Param = $DBName_Param, $Partner_Param

invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query -Variable $Param -ErrorAction SilentlyContinue
}

function set_witness (
    [string]$DBName,
    [string]$serverName,
    [string]$witnessName, 
    [string]$portnumber
)
{

$SQL_Query=@"
ALTER DATABASE `$(DataBaseName)
	SET WITNESS = `$(WitnessString)
GO
"@

if ($WitnessName.Contains(","))
{
    $WitnessName = $WitnessName.Substring(0,$WitnessName.IndexOf(","))
}

$DBName_Param = "DataBaseName=" + $DBName 
$Witness_Param = "WitnessString='TCP://" + $WitnessName + ":" + $portnumber + "'"
$Param = $DBName_Param, $Witness_Param

invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $SQL_Query -Variable $Param -ErrorAction SilentlyContinue

}

function Test_Port_BROKEN (
    [string]$ServerName, 
    [int]$portNunmber
)
{
     # Create a Net.Sockets.TcpClient object to use for
     # checking for open TCP ports.
     $Socket = New-Object Net.Sockets.TcpClient
        
     # Suppress error messages
     $ErrorActionPreference = 'SilentlyContinue'
        
     # Try to connect
     $Socket.Connect($ServerName, $portNumber)
        
          
     # Determine if we are connected.
     if ($Socket.Connected) 
     {
        $returnValue = 1
        $Socket.Close()
     }
     else 
     {
       $returnValue = 0
     }
      
     # Apparently resetting the variable between iterations is necessary.
     $Socket.Dispose()
     $Socket = $null

     return $returnValue
}

function CreateDB (
    [string]$DBName,
    [string]$ServerName,
    [string]$DataDir = "E:\Data",
    [string]$LogDir = "E:\Log"
)
{

$CreateDB_Query=@"
if db_id(`$(DBName1)) is null 
	CREATE DATABASE [`$(DBName2)] ON  PRIMARY 
	( NAME = N`$(DBName3), FILENAME = N`$(DBFile) , SIZE = 3072KB , FILEGROWTH = 1024KB )
	 LOG ON 
	( NAME = N`$(LogName), FILENAME = N`$(LogFile) , SIZE = 1024KB , FILEGROWTH = 10%)
	GO
"@

$DBFileName = write-output ($DataDir + "\" + $DBName + ".mdf")
$DBLogName = write-output ($DBName + "_log")
$DBLogFileName = write-output ($LogDir + "\" + $DBLogName + ".ldf")
$DBName1_Param = "DBName1='" + $DBName + "'"
$DBName2_Param = "DBName2=" + $DBName 
$DBName3_Param = "DBName3='" + $DBName + "'"
$DBFile_Param = "DBFile='" + $DBFileName + "'" 
$DBLogName_Param = "LogName='" + $DBLogName + "'"
$DBLogFile_Param = "LogFile='" + $DBLogFileName + "'"
$Param = $DBName1_Param, $DBName2_Param, $DBName3_Param, $DBFile_Param, $DBLogName_Param, $DBLogFile_Param

invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $CreateDB_Query -Variable $Param -ErrorAction SilentlyContinue 

}

function CONVERT_DRIVEPATH_TO_URL ([string]$DrivePath, $ServerName)
{
$DrivePath = $DrivePath.Replace(":", "$")
$URLPath = write-output ("\\" + $ServerName + "\" + $DrivePath)

return $URLPath
}

function MirrorDB (
    [string]$DBName,
    [int]$portnum = 1450, 
    [string]$sourceServer = "Ginger",
    [string]$mirrorServer = "MaryAnn",
    [string]$witnessServer = "Chong,50839",
    [string]$backupDir = "E:\Backups\mirror"
    )
{
$runDir = (Get-Location).Path
##########################################################################################
# import SQL module
##########################################################################################
if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
{
    if (Get-Module -Name SQLPS -ListAvailable) 
    {
        if ((Get-ExecutionPolicy) -ne 'Restricted')
        {
            Import-Module -Name SQLPS -DisableNameChecking
        } 
    }
    elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
    {
        Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
    }            
}
######################################
# The rest of the function
######################################
$sourceDirectoryListing = write-output ("SQLSERVER:\SQL\" + $sourceServer + "\DEFAULT\DATABASES")
$mirrorDirectoryListing = write-output ("SQLSERVER:\SQL\" + $mirrorServer + "\DEFAULT\DATABASES")
$SourceDBExists = dir $sourceDirectoryListing | Where {$_.Name -eq  $DBName} 
$mirrorDBExists = dir $mirrorDirectoryListing | Where {$_.Name -eq  $DBName}
if ($SourceDBExists)
{
    $FullDBFile = Backup_Database -DBName "$DBName" -BackDir $backupDir -ServerName $sourceServer -Mirror
    $sourceFullFile = CONVERT_DRIVEPATH_TO_URL -DrivePath $FullDBFile -ServerName $sourceServer
    $mirrorDir = CONVERT_DRIVEPATH_TO_URL -DrivePath $backupDir -ServerName $MirrorServer
    if ((get-location).Path -ne $rundir)
    {
        CD $runDir
    } 
    Copy-Item $sourceFullFile $mirrorDir
    if (!($mirrorDBExists))
    {
        CreateDB -DBName $DBName -ServerName $mirrorServer
    }
    Restore_Database -DBName $DBName -ServerName $mirrorServer -BackupFile $FullDBFile  
    $LogDBFile = Backup_Database -DBName "$DBName" -BackDir $backupDir -ServerName $sourceServer -Mirror -log
    $sourceLogFile = CONVERT_DRIVEPATH_TO_URL -DrivePath $LogDBFile -ServerName $sourceServer
    Copy-Item $sourceLogFile $mirrorDir
    Restore_Database -DBName $DBName -ServerName $mirrorServer -BackupFile $LogDBFile


    $mirrorport = create_endpoint -ServerName $mirrorServer -portnumber $portnum -role "Partner"
    $sourceport = create_endpoint -ServerName $sourceServer -portnumber $portnum -role "Partner"
    $witnessport = create_endpoint -ServerName $witnessServer -portnumber $portnum -role "Witness"

    set_partner -DBName $DBName -ServerName $mirrorServer -PartnerName $sourceServer -portnumber $sourceport.ToString()
    set_partner -DBName $DBName -ServerName $sourceServer -PartnerName $mirrorServer -portnumber $mirrorPort.ToString()
    set_witness -DBName $DBName -serverName $sourceServer -witnessName $witnessServer -portnumber $witnessport.ToString()
}

}

function MigrateDB (
    [string]$DBName, 
    [string]$SourceServer,
    [string]$DestinationServer,
    [string]$BackupDir = "E:\backups\migration"
    )
{
$sourceDirectoryListing = write-output ("SQLSERVER:\SQL\" + $sourceServer + "\DEFAULT\DATABASES")
$destDirectoryListing = write-output ("SQLSERVER:\SQL\" + $DestinationServer + "\DEFAULT\DATABASES")
$SourceDBExists = dir $sourceDirectoryListing | Where {$_.Name -eq  $DBName} 
$destDBExists = dir $destDirectoryListing | Where {$_.Name -eq  $DBName}
if ($SourceDBExists)
{
    $FullDBFile = Backup_Database -DBName "$DBName" -BackDir $backupDir -ServerName $sourceServer -Mirror
    $sourceFullFile = CONVERT_DRIVEPATH_TO_URL -DrivePath $FullDBFile -ServerName $sourceServer
    $destDir = CONVERT_DRIVEPATH_TO_URL -DrivePath $backupDir -ServerName $DestinationServer 
    Copy-Item $sourceFullFile $destDir
    if (!($destDBExists))
    {
        CreateDB -DBName $DBName -ServerName $DestinationServer
    }
    Restore_Database -DBName $DBName -ServerName $DestinationServer -BackupFile $FullDBFile  -recovery

    $destFileName = $destDir + $sourceFullFile.SubString($sourceFullFile.LastIndexOf("\"),($sourceFullFile.Length - $sourceFullFile.LastIndexOf("\")))
    Remove-Item -Path $sourceFullFile -Force
    Remove-Item -Path  $destFileName -Force
    
        
}

}