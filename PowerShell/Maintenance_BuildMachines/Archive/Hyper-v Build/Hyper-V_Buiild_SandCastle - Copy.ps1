param ([string]$ServerName = "Default", [strng]$DiskDir = "E:\Hyper-V\Disks", $RAM = 4GB, [string]$Location = "E:\Hyper-V", $DriveNumber = 4, [swich]$NetBoot, [switch]$CDBoot, [string]$CD_ISO = ""  )

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

				                   
$Server_HD_Loc = write-output ($DiskDir + "\" + $ServerName + ".vhdx")
$Server_Log_HD_Loc = write-output ($DiskDir + "\" + $ServerName + "-Log.vhdx")
$Server_Data_HD_Loc = write-output ($DiskDir + "\" + $ServerName + "-Data.vhdx")
$Server_Bak_HD_Loc = write-output ($DiskDir + "\" + $ServerName + "-Bak.vhdx")

$Server_HD_0_Size = 80GB
$Server_Log_HD_Size = 50GB
$Server_Data_HD_Size = 100GB
$Server_Bak_HD_Size = 100GB

$NetworkSwitch1 = "Hyper-V Wan Switch"	# Name of the Network Switch

$CD_ISO = "C:\Users\ktobola\Desktop\SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-4_MLF_X19-82891.iso"	        # Windows Server 2008 ISO
#$WSVFD = "C:\Labfiles\W2K8R2.vfd"	# Windows Server 2008 Virtual Floppy Disk with autounattend.xml file

# Create VM Folder and Network Switch
MD $VM_Location -ErrorAction SilentlyContinue


#declare the network card that will be used for the virtual switch
$net = Get-NetAdapter -Name 'Ethernet 2'

#create and declare the switch
$TestSwitch = Get-VMSwitch -Name $NetworkSwitch1 -ErrorAction SilentlyContinue; if ($TestSwitch.Count -EQ 0){New-VMSwitch -Name $NetworkSwitch1 -AllowManagementOS $True -NetAdapterName $net.Name}


# Create Virtual Machines
New-VM -Name $ServerName -Path $VM_Location -MemoryStartupBytes $SRAM -SwitchName $NetworkSwitch1 -Generation 2
Add-VMScsiController -VMName $ServerName

if (!(test-path $Server_HD_Loc)) { $BootFromNet = 1 } else { $BootFromNet = 0}
if (!(test-path $Server_HD_Loc)) { New-VHD -Path $Server_HD_Loc -SizeBytes $Server_HD_0_Size }
if (!(test-path $Server_Log_HD_Loc)) { New-VHD -Path $Server_LOG_HD_Loc -SizeBytes $Server_LOG_HD_Size }
if (!(test-path $Server_Data_HD_Loc)) { New-VHD -Path $Server_DATA_HD_Loc -SizeBytes $Server_DATA_HD_Size }
if (!(test-path $Server_Bak_HD_Loc)) { New-VHD -Path $Server_BAK_HD_Loc -SizeBytes $Server_BAK_HD_Size }

Add-VMDvdDrive -VMName $ServerName -ControllerNumber 1 -ControllerLocation 0 -Path $Install_ISO
Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation 1 -Path $Server_HD_Loc
Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation 2 -Path $Server_LOG_HD_Loc
Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation 3 -Path $Server_DATA_HD_Loc
Add-VMHardDiskDrive -VMName $ServerName -ControllerType SCSI -ControllerNumber 1 -ControllerLocation 4 -Path $Server_BAK_HD_Loc

##Add-VMNetworkAdapter -VMName $ServerName -SwitchName $NetworkSwitch1
# Configure Virtual Machines
Set-VMDvdDrive -VMName $ServerName -Path $Install_ISO
#Set-VMFloppyDiskDrive -VMName $ServerName -Path $WSVFD
get-vm -name $ServerName | Get-VMNetworkAdapter 
$VMNet = get-vm -name $ServerName | Get-VMNetworkAdapter
Set-VMFirmware -VMName $ServerName -FirstBootDevice $VMNet
Start-VM $ServerName 
