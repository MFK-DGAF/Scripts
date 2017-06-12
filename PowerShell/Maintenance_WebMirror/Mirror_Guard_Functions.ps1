. "E:\automation\Maintenance_WebMirror\Mirror_Functions.ps1"
. "E:\automation\Maintenance_WebMirror\DNS_Update_Functions.ps1"

function FILE_EXISTS (
    [string]$FileName
    )
{
        if ($FileName)
        {
            if (Test-Path $FileName -ErrorAction SilentlyContinue)
            {
                $returnVal = 1
            }
            else
            {   
                $returnval = 0
            }
       }
       else 
       {
            $returnval = 0
       }
       return $returnVal
    }

function GET_DB_List (
    [string]$DBListFile, 
    [string]$ServerName
    )
{
    
    
    if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
    {
        $runDir = (Get-Location).Path
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
        cd $runDir
    }
    
    if (File_Exists $DBListFile)
    {
           
        $DBList = get-content $DBListFile
        $GetDirectoryText = write-output ("SQLSERVER:\SQL\" + $ServerName + "\DEFAULT\DATABASES")
        $DBListInfo = dir $GetDirectoryText | select-object Name, Status, IsMirroringEnabled, MirroringID, MirroringPartner, MirroringStatus, MirroringWitness, MirroringWitnessStatus | where {$_.Name -in $DBList}
    }    
    else
    {
        $GetDirectoryText = write-output ("SQLSERVER:\SQL\" + $ServerName + "\DEFAULT\DATABASES")
        $DBListInfo = dir $GetDirectoryText | select-object Name, Status, IsMirroringEnabled, MirroringID, MirroringPartner, MirroringStatus, MirroringWitness, MirroringWitnessStatus 
    }
    #Remove-Variable $GetDirectoryText, $runDir, $DBList, $ServerName -ErrorAction SilentlyContinue

    return $DBListInfo
} 

function  GET_DB_Info (
    [string]$DBName,
    [string]$ServerName
    )
{
    if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
    {
        $runDir = (Get-Location).Path
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
        cd $runDir
    }
    
    $GetDirectoryText = write-output ("SQLSERVER:\SQL\" + $ServerName + "\DEFAULT\DATABASES")
    $DBInfo = dir $GetDirectoryText | select-object Name, Status, IsMirroringEnabled, MirroringID, MirroringPartner, MirroringStatus, MirroringWitness, MirroringWitnessStatus | where {$_.Name -eq $DBName}

    #Remove-Variable $GetDirectoryText, $runDir, $DBName, $ServerName -ErrorAction SilentlyContinue
    return $DBInfo
}

function GET_OTHER_SERVER (
    [string]$Alias,
    [string]$Server1,
    [string]$Server2
    )
{
    $currentAddress = [System.Net.Dns]::GetHostAddresses($Alias).IPAddressToString
    $Server1Address = [System.Net.Dns]::GetHostAddresses($Server1).IPAddressToString
    $Server2Address = [System.Net.Dns]::GetHostAddresses($Server2).IPAddressToString
    
    $maxAddress1 = get_Max_Address $Server1Address
    $maxAddress2 = get_Max_Address $Server2Address
    
    if (($maxAddress1 -eq $currentAddress) -and ($maxAddress2 -ne $currentAddress))
    {
        $returnValue = $maxAddress2
    }
    if (($maxAddress2 -eq $currentAddress) -and ($maxAddress1 -ne $currentAddress))
    {
        $returnValue = $maxAddress1
    }
    if (($maxAddress2 -ne $currentAddress) -and ($maxAddress1 -ne $currentAddress))
    {
        $returnValue = 0
    }
    if (($maxAddress2 -eq $currentAddress) -and ($maxAddress1 -eq $currentAddress))
    {
        $returnValue = 0
    }

    #Remove-Variable $currentAddress, $Server1Address, $Server2Address, $Alias, $Server1, $Server2 -ErrorAction SilentlyContinue
    return $returnValue

}

function FAILOVER_DB (
    [string]$DBName, 
    [string]$ServerName
)
{
    
    ##Import SQL Modules
    if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
    {
        $runDir = (Get-Location).Path
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
        cd $runDir
    }
    

$query = @"
ALTER DATABASE `$(DBNamen) SET PARTNER FAILOVER
"@

    $Param = "DBNamen=" + $DBName
    $failover = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $query -Variable $Param -ErrorAction SilentlyContinue
}


function GET_PRIMARY_SERVER (
    [string]$Server1,
    [string]$Server2, 
    [string]$KEYDB
)
{
    #get the server values
    if ($Server1)
    {
        $Server1Test = TEST_KEYDB -hostname $Server1 -KeyDB $KEYDB
    }
    if ($Server2)
    {
        $Server2Test = TEST_KEYDB -hostname $Server2 -KeyDB $KEYDB
    }
    #Set the output based on those values.
    if (($Server1Test) -and (!($Server2Test)))
    {
        $outValue = $Server1
    }
    if (($Server2Test) -and (!($Server1Test)))
    {
        $outValue = $Server2
    }
    if (!($outValue))
    {
        $outValue = 0
    }

    return $outValue
}

function CHECK_MIRROR_MAIN (
    [string]$Alias, 
    [string]$Server1, 
    [string]$Server2,
    [string]$KeyDB, 
    [string]$DBListFile = "E:\automation\Maintenance_WebMirror\DBList.txt",
    [string]$emailRecipient = "Torsten_Spooner@rush.edu",
    [string]$emailServer = "cheech"
    )
{
    $errorCount = 0
    $messageCount = 0
    $AliasIP = HostName_To_Address $Alias
    $mirrorAddress = GET_OTHER_SERVER -Alias $AliasIP -Server1 $Server1 -Server2 $Server2

    $primaryServer = GET_PRIMARY_SERVER -Server1 $AliasIP -server2 $mirrorAddress -KEYDB $KeyDB
    $notPrimaryServer = GET_OTHER_SERVER -Alias $primaryServer -server1 $Server1 -Server2 $Server2
    if (($primaryServer) -and ($notPrimaryServer))
    {
        $PrimaryList = GET_DB_LIST -DBListFile $DBListFile -ServerName $primaryServer
        foreach ($DB in $PrimaryList)
        {
            switch ($DB.Status)
                {
                    "Normal" 
                        {
                            if ($DB.MirroringStatus -ne "Synchronized")
                            {
                                $errorCount++
                                $errorMessage += write-output ("The database " + $DB.Name + " is no longer synchronized. `n")
                            }
                        }
                    "Restoring"   
                        {
                            if ($DB.MirroringStatus -eq "Synchronized")
                            {
                                FAILOVER_DB $DB.Name $notPrimaryServer
                                $messageCount++
                                $message += write-output ("The database " + $DB.Name + " has been failed over to " + $primaryServer + "`n")  
                            }
                            else
                            {
                                $errorCount++
                                $errorMessage += write-output ("The database " + $DB.Name + " is " + $DB.Status + " on " + $primaryServer + ".`n")
                            }
                        }
                    Default
                        {
                            $errorCount++
                            $errorMessage += write-output ("The database " + $DB.Name + " is " + $DB.Status + " on " + $primaryServer + ".`n")
                        }

                }
        }
    }
    else
    {
        if (!($primaryServer))
        {
            $errorCount++
            $errorMessage += write-output ("There is no valid primary database server.`n")
        }
        if (!($notPrimaryServer))
        {
            $errorCount++
            $errorMessage += write-output ("There is no valid mirror server.`n")
        }
    }

    if (($errorCount) -or ($messageCount))
    {
        $smtpFrom = "DBMirror@rush-health.com"
        $messageSubject = "Database Mirroring Events"
        $body = $errorMessage + $message
        $smtpTo = $emailRecipient
        send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$emailServer"	
    }
    $count = $errorcount + $messageCount
    return $count
    #Remove-Variable $PrimaryList, $mirrorDB, $mirrorAddress, $errorCount, $errorMessage, $messageCount, $message, $AliasIP, $Alias -ErrorAction SilentlyContinue
}
    
    
    