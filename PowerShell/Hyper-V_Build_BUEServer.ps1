If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

$VMName = "BUEServer"
$VHDXSize = 127GB
$MemSize = 4096mb
$Gen = 2
$ProcNumber = 2
$OSISOPath = "C:\vm\iso"
$OSISOName = "SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-4_MLF_X19-82891"
$BUEISOPath = "C:\vm\iso"
$BUEISOName = "BackupExec_15_14.2_FP4_MultiPlatforms_Multilingual"
$VMPath = "c:\vm"

#Creates the VM folder structure
New-Item -ItemType directory -Path "$VMPath\$VMName"

#Creates the vhdx file
New-VHD -Path $VMPath\$VMName\$VMName.vhdx -Dynamic -SizeBytes $VHDXSize

#Creates the VM in Hyper-V Manager
New-VM -Name $VMName -VHDPath $VMPath\$VMName\$VMName.vhdx -MemoryStartupBytes $MemSize -Generation $Gen
#Sets all other settings
Set-VMProcessor $VMName -Count $ProcNumber
Add-VMDvdDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 1 -Path $OSISOPath\$OSISOName.iso
Add-VMDvdDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 2 -Path $BUEISOPath\$BUEISOName.iso
Get-VM -Name $VMName | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "Internal Hyper-V"
$DVDDrive = Get-VMDvdDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 1
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive