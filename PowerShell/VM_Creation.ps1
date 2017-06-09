$VMName = Read-Host "Enter name of VM"
#$VMSize = Read-Host "Enter size of VHDX"
$VHDXSize = 127GB
[int64]$MemSize = 1GB*(Read-Host "Enter Size(GB) of Memory")
$Gen = Read-Host "Enter the Generation number to create"
$ProcNumber = Read-Host "Enter the number of vitrual processors"
$ISOPath = Read-Host "Enter the location of the ISO to use"
$ISOName = Read-Host "Enter the name of the ISO"
$VMPath = "c:\vm"

#Creates the VM folder structure
New-Item -ItemType directory -Path "$VMPath\$VMName"

#Creates the vhdx file
New-VHD -Path $VMPath\$VMName\$VMName.vhdx -Dynamic -SizeBytes $VHDXSize

#Creates the VM in Hyper-V Manager
New-VM -Name $VMName -VHDPath $VMPath\$VMName\$VMName.vhdx -MemoryStartupBytes $MemSize -Generation $Gen
#Sets all other settings
Set-VMProcessor $VMName -Count $ProcNumber
Add-VMDvdDrive -VMName $VMName -Path $ISOPath\$ISOName.iso
Get-VM -Name $VMName | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "Internal Hyper-V"
$DVDDrive = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive