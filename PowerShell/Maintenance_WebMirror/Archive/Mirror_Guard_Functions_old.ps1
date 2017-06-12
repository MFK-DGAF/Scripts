if ($mirrorAddress)
    {
        if (TEST_KEYDB -hostname $AliasIP -KeyDB $KeyDB)
        {
            $PrimaryList = GET_DB_LIST -DBListFile $DBListFile -ServerName $AliasIP

            foreach ($PrimaryDB in $PrimaryList)
            {
                if (($PrimaryDB.Status -eq "Restoring") -and ($PrimaryDB.MirroringStatus -eq "Synchronized") -and ($PrimaryDB.Name -ne $KeyDB)) 
                {
                    $mirrorDB = GET_DB_Info $PrimaryDB.Name $mirrorAddress
                    if (($mirrorDB.Status -eq "Normal") -and ($mirrorDB.MirroringStatus -eq "Synchronized"))
                    {
                        FAILOVER_DB $mirrorDB.Name $mirrorAddress
                        $messageCount++
                        $message += write-output ("The database " + $mirrorDB.Name + " has been failed over to " + $AliasIP + "`n")                        
                    }
                    else
                    {
                        $errorCount++
                        $errorMessage += write-output ("The database " + $mirrorDB.Name + " is restoring on the primary server, but either not synchronized or not present on the secondary. `n")
                        $errorMessage += write-output ("The db " + $mirrorDB.Name + " on " + $mirrorAddress + " has the status of " + $mirrorDB.Status + " and the mirroring Status of " + $mirrorDB.MirroringStatus + ". `n")
                                         
                    }
                }
            }
        }
        else
        {
            if (TEST_KEYDB -hostname $mirroraddress -KeyDB $KeyDB)
            {
                $SecondaryList = GET_DB_LIST -DBListFile $DBListFile -ServerName $MirrorAddress
                foreach ($DB in $SecondaryList)
                {
                    if (($DB.Status -eq "Restoring") -and ($DB.MirroringStatus -eq "Synchronized") -and ($DB.Name -ne $KeyDB)) 
                    {
                        $AliasDB = GET_DB_Info $DB.Name $AliasIP
                        if (($AliasDB.Status -eq "Normal") -and ($AliasDB.MirroringStatus -eq "Synchronized"))
                        {
                            FAILOVER_DB $AliasDB.Name $AliasIP
                            $messageCount++
                            $message += write-output ("The database " + $AliasDB.Name + " has been failed over to " + $mirrorAddress + "`n")                        
                        }
                        else
                        {
                            $errorCount++
                            $errorMessage += write-output ("The database " + $AliasDB.Name + " is restoring on the primary server, but either not synchronized or not present on the secondary. `n")
                        }
                    }        
                }
            }
            else
            {
                $errorCount++
                $errorMessage += write-output ("The KeyDB '" + $KeyDB + "' did not respond on " + $Alias + " or " + $mirrorAddress + "`n")
            }
        }
        
    }
    else
    {
        $errorCount++
        $errorMessage += write-output ("The secondary server is not available. `n")
    }