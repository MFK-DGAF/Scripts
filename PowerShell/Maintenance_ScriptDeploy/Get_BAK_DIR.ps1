function Get_Bak_Dir ([string]$ServerName = $env:COMPUTERNAME)

{
    $ServerDrives = Get-WmiObject -ComputerName $Servername Win32_LogicalDisk

    foreach ($Drive in $ServerDrives)
    {
        if ($Drive.DriveType -eq 3)
        {
            $LabelString = write-output ($Drive.DeviceID + "\")
            $directoryName = write-output ( "\\" + $ServerName + "\" + $LabelString.Replace(":","$"))
            $tempBaks = get-childitem $directoryName -include ("*.bak","*.bak.bz2", "*.bak.rar", "*.bak.zip") -Recurse -erroraction silentlycontinue
            if ($biggestBaks.count -lt $tempBaks.count)
            {
                $biggestBaks = $tempBaks
            }
    
        }
    }

    $bakHash = @{}
    foreach ($bak in $biggestBaks)
    {
        $dir = $bak.DirectoryName.SubString(0, $bak.DirectoryName.LastIndexof("\"))
        if ($bakHash.ContainsKey($dir))
        {
            $bakHash.$dir++
        }
        else 
        {
            $bakHash.Add($dir, 1)
        }
    }

    $maxCount = 0
    $maxValue = ""
    foreach ($BakLoopCounter in $bakHash.GetEnumerator())
    {
        if ($($BakLoopCounter.Value) -gt $maxCount)
        {
            $maxValue = $BakLoopCounter.Name
            $maxCount = $BakLoopCounter.Value
        }
    }

    if (($MaxValue -eq $Null) -or ($maxValue -eq ""))
    {
        $maxValue = 0
    }

    return $MaxValue
}


function Get_Dir ([string]$ServerName = $env:COMPUTERNAME, [string]$DirName = "HealthCheck", [string]$parent = "automation", [switch]$exact, [switch]$exclude)
{
    $ServerDrives = Get-WmiObject -ComputerName $Servername Win32_LogicalDisk
    if ($exact)
    {
        $SearchDir = $Dirname
    }
    else
    {
        $SearchDir = write-output ("*" + $DirName + "*")
    }

    foreach ($Drive in $ServerDrives)
    {
        if ($Drive.DriveType -eq 3)
        {
            $LabelString = write-output ($Drive.DeviceID + "\")
            $directoryName = write-output ( "\\" + $ServerName + "\" + $LabelString.Replace(":","$"))
            try
            {
                $tempBaks = get-childitem $directoryName -include ($SearchDir) -Recurse -erroraction silentlycontinue -ErrorVariable e$ | ?{ $_.PSIsContainer }
            }
            catch
            { 
                write-output "error" 
            }
            if ($biggestBaks.count -lt $tempBaks.count)
            {
                $biggestBaks = $tempBaks
            }
    
        }
    }

    if ($exclude)
    {
        if ($biggestBaks.Count -gt 1)
        {
            $parent = write-output ("*"+ $parent + "*")
            foreach ($dir in $biggestBaks)
            {
                if (($dir.FullName -notlike $parent) -or ($parent -eq "**"))
                {
                    $outputDir = $dir.FullName
                }
            }
        }
        else
        {
            if ($biggestBaks.FullName -notlike $parent)
            {
                $outputDir = $biggestBaks.FullName 
            }
            else 
            {
                $outputDir = $null
            }
        }
    }
    else
    {
        if ($biggestBaks.Count -gt 1)
        {
            $parent = write-output ("*"+ $parent + "*")
            foreach ($dir in $biggestBaks)
            {
                if (($dir.FullName -like $parent) -or ($parent -eq "**"))
                {
                    $outputDir = $dir.FullName
                }
            }
        }
        else
        {
            $outputDir = $biggestBaks.FullName 
        }    
    }

    if (($outputDir -eq "") -or ($outputDir -eq $Null))
    {
        $outputDir = 0
    }

    return $outputDir
}


MIGRATE_FILE ([string]$File, [string]$DestDir, [string]$ServerName = $env:COMPUTERNAME)
{
    $fileExtension = $File.SubString($File.LastIndexof("."), ($File.Length - $File.LastIndexof(".")))
    $shortfilename = $File.SubString(($File.LastIndexOf("\")+1), ($File.Length - ($File.LastIndexOf("\")+1)))
    $dateString = get-date -Format "yyyyMMdd"
    $archiveDir = $DestDir + "archive\"
    $archiveName = $archiveDir + $shortfilename.Replace($fileExtension, "") + "_archive_" + $dateString + $fileExtension

    if ((test-path $DestDir) -and (Test-Path $File))
    {
        if ($DestDir.LastIndexof("\") -ne $DestDir.length)
        {
            $DestDir = $DestDir + "\" 
            $destinationPath = $DestDir + $shortfilename
        }
        else
        {
            $destinationPath = $DestDir + $shortfilename
        }
        
        if (test-path $destinationPath)
        {
               if (!(test-path $archiveDir))
               {
                    New-Item -Path $archiveDir -type directory
               }
               move-item -Path $destinationPath -Destination $archiveName
        }
        copy-Item -Path $File -Destination $destinationPath
        $outvalue = 1

    }
    else 
    {
        $outvalue = 0
    }

    return $outvalue
}
