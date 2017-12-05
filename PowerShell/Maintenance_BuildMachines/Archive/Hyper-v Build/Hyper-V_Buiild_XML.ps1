param (
[string]$ServerName = "Default_VM", 
[strIng]$DiskDir = "E:\Hyper-V\Disks", 
[string]$Location = "E:\Hyper-V", 
[string]$CD_ISO = "", 
$Net = "Ethernet 2", 
$SwitchName = "Hyper-V Wan Switch", 
$NetworkAdapter =  'Ethernet 2',
$XMLFile = "E:\automation\Maintenance_BuildMachines\Server_Definitions\test.xml"
)

##runs as Admin if not already running as admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}


#######################################################
# Function to create hard drives. 
#######################################################

function make_drive (
    [string]$ServerName, 
    [string]$DriveNumber, 
    [string]$DriveSize, 
    [string]$DriveType,
    [string]$DiskGen, 
    [string]$DiskDir
)
{
    if ($diskGen -eq 1)
    {
        $extension = ".vhd"
    }
    else
    {
        $extension = ".vhdx"
    }
    $Drive_Location = write-output ($DiskDir + "\" + $ServerName + "_" + $DriveNumber + $extension)
    if (!(test-path $Drive_Location)) 
    {
        New-VHD -Path $Drive_Location -SizeBytes (Invoke-Expression $DriveSize)
        $returnMessage = ("The drive " + $Serverame + "_" + $DriveNumber + $extension+ " was created in the directory : " + $DiskDir)
    }
    else 
    {
        $returnMEssage = ("The drive " + $Serverame + "_" + $DriveNumber + $extension+ " already existed in the directory : " + $DiskDir)
    }
   
}


#######################################################
# Function to add the drive to the server
#######################################################

function add_drive (
    [string]$ServerName, 
    [string]$DriveNumber, 
    [string]$DriveType,
    [string]$DiskDir
)  
{
    $Drive_Location = write-output ($DiskDir + "\" + $ServerName + "_" + $DriveNumber + ".vhdx")
    Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation $DriveNumber -Path $Drive_Location


}


#######################################################
# Import the XML File and assign variables
#######################################################

[xml]$Specs = Get-Content $XMLFile



# Create VM Folder and Network Switch
MD $Location -ErrorAction SilentlyContinue

New-VM -Name $ServerName -Path $Location -MemoryStartupBytes $RAM -SwitchName $NetworkSwitch1 -Generation 2
Add-VMScsiController -VMName $ServerName



#####################################
##Create the VHDs
####################################

                

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
