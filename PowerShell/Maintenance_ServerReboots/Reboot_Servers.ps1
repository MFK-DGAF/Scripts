param([string]$file="E:\Automation\Maintenance_ServerReboots\Reboot_Lists\FourInTheAM_Reboots.txt")

If (test-path $fFile) 
{
    $Reboot_List = Get-Content $file
}
else
{
    write-host ($file + "does not exist")
}

if ($Reboot_List.Count -gt 0)
{
    foreach ($server in $Reboot_List)
    {
        shutdown -r -m \\$server
    }
}

      