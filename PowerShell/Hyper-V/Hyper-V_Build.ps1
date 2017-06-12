# Variables
$ServerName = "RHSandCastle"		                                   # Name of VM running Server Operating System
$SRAM = 4GB				                                       # RAM assigned to Server Operating System
$Server_OS_HD_Size = 80GB				                   
$Server_OS_HD_Loc = "E:\Hyper-V\Disks\RHSandCastle.vhdx"
$Server_Log_HD_Size = 50GB
$Server_Log_HD_Loc = "E:\Hyper-V\Disks\RHSandCastle-Logs.vhdx"
$Server_Data_HD_Size = 100GB
$Server_Data_HD_Loc = "E:\Hyper-V\Disks\RHSandCastle-Data.vhdx"
$Server_Bak_HD_Size = 100GB
$Server_Bak_HD_Loc = "E:\Hyper-V\Disks\RHSandCastle-Backup.vhdx"

$VM_Location = "E:\Hyper-V"			        # Location of the VM and VHDX files
$NetworkSwitch1 = "RH_Network_Switch"	# Name of the Network Switch

$WSISO = "C:\Labfiles\W2K8R2.iso"	        # Windows Server 2008 ISO
$WSVFD = "C:\Labfiles\W2K8R2.vfd"	# Windows Server 2008 Virtual Floppy Disk with autounattend.xml file

# Create VM Folder and Network Switch
MD $VM_Location -ErrorAction SilentlyContinue
$TestSwitch = Get-VMSwitch -Name $NetworkSwitch1 -ErrorAction SilentlyContinue; if ($TestSwitch.Count -EQ 0){New-VMSwitch -Name $NetworkSwitch1 -SwitchType Private}

# Create Virtual Machines
New-VM -Name $ServerName -Path $VM_Location -MemoryStartupBytes $SRAM -NewVHDPath $VMLOC\$SRV1.vhdx -NewVHDSizeBytes $SRV1VHD -SwitchName $NetworkSwitch1
Add-VMScsiController -VMName $VMName
Add-VMDvdDrive -VMName $VMName -ControllerNumber 1 -ControllerLocation 0 -Path $InstallMedia
Add-VMHardDiskDrive -VMName $ServerName 

# Configure Virtual Machines
Set-VMDvdDrive -VMName $CLI1 -Path $W7ISO
Set-VMDvdDrive -VMName $SRV1 -Path $WSISO
Set-VMFloppyDiskDrive -VMName $CLI1 -Path $W7VFD
Set-VMFloppyDiskDrive -VMName $SRV1 -Path $WSVFD
Start-VM $SRV1
Start-VM $CLI1