param (
[string]$ServerName = "Default_VM", 
[strIng]$DiskDir = "E:\Hyper-V\Disks", 
$RAM = 4GB, 
[string]$Location = "E:\Hyper-V", 
$DriveNumber = 4, 
[string]$CD_ISO = "", 
[int]$defaultDrive = "50", 
[array]$DriveArray = 0, 
$Net = "Ethernet 2", 
$SwitchName = "Hyper-V Wan Switch", 
$NetworkAdapter =  'Ethernet 2', 
[switch]$NetBoot, 
[switch]$CDBoot, 
[switch]$Script
)

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}


# Create VM Folder and Network Switch
MD $Location -ErrorAction SilentlyContinue

New-VM -Name $ServerName -Path $Location -MemoryStartupBytes $RAM -SwitchName $NetworkSwitch1 -Generation 2
Add-VMScsiController -VMName $ServerName



#####################################
##Create the VHDs
####################################
$Counter = 0
if (($DriveNumber -eq $DriveArray.Count) -and ($DriveArray -ne 0))
{
    foreach ($drive in $DriveArray)
    {
        if (($drive -eq "") -or ($drive -eq $null) -or ($drive -eq 0))
        {
            if ($script)
            {
                $DriveSize = write-output ($defaultDrive + "GB")
            }
            else
            {
                $DriveSizeNumber = Read-Host ("Enter Size in GB for Drive " + $counter + ": ")
                $DriveSize = write-output ($DriveSizeNumber + "GB")
            }
        }
        else
        {
            if ($drive -gt 0)
            {
                $DriveSize = write-ouput ($drive + "GB")
            }
        }
        $Drive_Location = write-output ($DiskDir + "\" + $ServerName + "_" + $counter + ".vhdx")
        if (!(test-path $Drive_Location)) { New-VHD -Path $Drive_Location -SizeBytes (Invoke-Expression $DriveSize) }
        $counter++
        Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation $Counter -Path $Drive_Location
    }
}
else
{
    for ($counter = 0;  $counter -lt $DriveNumber; $counter++)
    {
        if ($script)
            {
                $DriveSize = write-output ($defaultDrive + "GB")
            }
            else
            {
                $DriveSizeNumber = Read-Host ("Enter Size in GB for Drive " + $counter + ": ")
                $DriveSize = write-output ($DriveSizeNumber + "GB")
            }
        $Drive_Location = write-output ($DiskDir + "\" + $ServerName + "_" + $counter + ".vhdx")
        if (!(test-path $Drive_Location)) { New-VHD -Path $Drive_Location -SizeBytes (Invoke-Expression $DriveSize) }
        Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation ($Counter + 1) -Path $Drive_Location      
    }
}
                

$NetworkSwitch1 = $SwitchName	# Name of the Network Switch


#declare the network card that will be used for the virtual switch
$net = Get-NetAdapter -Name $NetworkAdapter 'Ethernet 2'

#create and declare the switch
$TestSwitch = Get-VMSwitch -Name $NetworkSwitch1 -ErrorAction SilentlyContinue; if ($TestSwitch.Count -EQ 0){New-VMSwitch -Name $NetworkSwitch1 -AllowManagementOS $True -NetAdapterName $net.Name}


# Create Virtual Machines


if ($CD_ISO -ne "")
{
    Add-VMDvdDrive -VMName $ServerName -ControllerNumber 1 -ControllerLocation 0 -Path $CD_ISO
    Set-VMDvdDrive -VMName $ServerName -Path $CD_ISO
}
else 
{
    Add-VMDvdDrive -VMName $ServerName -ControllerNumber 1 -ControllerLocation 0 
}

if ($CDBoot)
{
    $Dvd = get-vm -name $ServerName | Get-VMDvdDrive
    Set-VMFirmware -VMName $ServerName -FirstBootDevice $VMNet
}

if ($NetBoot)
{
    $VMNet = get-vm -name $ServerName | Get-VMNetworkAdapter
    Set-VMFirmware -VMName $ServerName -FirstBootDevice $VMNet
}

Start-VM $ServerName 
