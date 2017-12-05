param (
[string]$ServerName = "Default_VM", 
[strIng]$DiskDir = ".\Disks", 
[string]$Location = "E:\Hyper-V", 
[string]$CD_ISO = "",
$SwitchName = "WAN", 
$NetworkAdapter =  'WAN',
$XMLFile = "E:\automation\Maintenance_BuildMachines\Server_Definitions\VM_Gen1_Template.xml", 
$StartRAMDefault = "32GB"
)

##runs as Admin if not already running as admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

###create function to logic test the xml file
#check for overlap in drive usage (controller and port)
#ensure that gen 1 machines have 1 ide drive to boot to
# (Invoke-Expression $DriveSize) 

function make_drive (
    [string]$ServerName, 
    [string]$DriveNumber, 
    [string]$DriveSize, 
    [string]$DriveType,
    [string]$DiskGen, 
    [string]$DiskDir
)
{
    #######################################################
    # Function to create hard drives. 
    #######################################################
    #todo, check to see if vhd file is greater than 2tb
    if ($diskGen -eq 1)
    {
        $extension = ".vhd"
    }
    else
    {
        $extension = ".vhdx"
    }
    $Drive_Location = write-output ($DiskDir + "\" + $ServerName + "_" + $DriveNumber + $extension)
    if (!(test-path $Drive_Location -ErrorAction SilentlyContinue)) 
    {
        $output = New-VHD -Path $Drive_Location -SizeBytes (Invoke-Expression $DriveSize)
        $returnMessage = write-output($Servername + "_" + $DriveNumber + $extension) 
    }
    else 
    {
        $returnMessage = write-output($Servername + "_" + $DriveNumber + $extension) 
    }
    if (test-path $Drive_Location -ErrorAction SilentlyContinue)
    {
        if ($returnMessage)
        {
            return $returnMessage
        }
        else 
        {
            return 0
        }
    }
    else 
    {
        return 0
    }
}

function add_drive (
    [string]$ServerName, 
    [string]$DriveNumber, 
    [string]$DriveType,
    [string]$DiskDir,
    [string]$DriveName, 
    [string]$DiskGen, 
    [int]$controllerNo
)  
{
    #######################################################
    # Function to add the drive to the server
    #######################################################
    if (!($controllerNo))
    {
        $controllerNo = 0
    }
    if (($controllerNo -gt 3) -and ($controllerType -eq "SCSI"))
    {
        $controllerNo = 0
    }
    if (($controllerNo -gt 1) -and ($controllerType -eq "IDE"))
    {
        $controllerNo = 0
    }

    #test if controller type is valid
    if (($drivetype -eq "SCSI") -or ($drivetype -eq "IDE"))
    {
        #test if controller exists
        if ($drivetype -eq "SCSI")
        {
            while ($x -lt 4)
            {
                if (!(Get-VMScsiController -VMName $ServerName -ControllerNumber $ControllerNo -ErrorAction SilentlyContinue))
                {
                    Add-VMScsiController -VMName $ServerName    
                    $x++
                }
                else
                {
                    $x = 5
                }
            }
        }
        if ($drivetpye -eq "IDE")
        {
            if (!(Get-VMIDEController -VMName $ServerName -ControllerNumber $ControllerNo -ErrorAction SilentlyContinue))
            {
                Add-VMIDEController -VMName $ServerName                
            }
        }
    
    
        #add the drives
    
        $diskPath = Write-Output ($diskDir + "\" + $DriveName)
        if (test-path $diskPath -ErrorAction SilentlyContinue)
        {
            Add-VMHardDiskDrive -VMName $ServerName  -ControllerType $DriveType -ControllerNumber $controllerNo -ControllerLocation $DriveNumber -Path $diskPath
        }
        else 
        {
            return 0
        }
    }
    else 
    {
        return 0
    }
}

function make_dir (
    [string]$dir
)
{
    if (!(test-path $dir))
    {
        MD $Dir   
    }

    if (test-path $dir)
    {
        return 1
    }
    else
    {
        return 0
    }
}

function add_optical (
    [string]$serverName, 
    [string]$ISO
)
{
    if (!(test-path $ISO -ErrorAction SilentlyContinue))
    {
        $ISO = ""
    } 
    if (($ISO -ne "") -and ($ISO -ne $null))
    {
        Add-VMDvdDrive -VMName $ServerName -Path $ISO
        $returnvalue = 1
    }
    else 
    {
        Add-VMDvdDrive -VMName $ServerName 
        $returnvalue = 0
    }
    return $returnvalue
}

function make_VM (
    [string]$ServerName, 
    [string]$RAM,
    [string]$Location,
    $Gen
)
{
    if ($Ram.GetType().Name -like "int*")
    {
        $Ram = write-ouput ($Ram + "GB")
    }
    if ($gen.gettype().Name -notlike "int*")
    {
        $gen = [convert]::ToInt32($gen, 10)
    }
    
    if ($gen.GetType().Name -like "int*")
    {
        $results = New-VM -Name $ServerName -Path $Location -MemoryStartupBytes (invoke-expression $RAM) -Generation $Gen
    }
    else
    {
        $results = write-output ("The virtual machine " + $ServerName + " has not been created. The generation type was not a valid integer.")
    }
    return $results
}

function set_Boot (
    [string]$ServerName, 
    [string]$BootMode, 
    $Gen
)
{
    if ($Gen.GetType().Name -notlike "int*")
    {
        $gen = [convert]::ToInt32($gen, 10)
    }
    if ($Gen -eq 2)
    {
        switch ($BootMode){
        "DVD" {
                $DVD = @(get-vm -name $ServerName | Get-VMDvdDrive)[0]
                Set-VMFirmware -VMName $ServerName -FirstBootDevice $DVD
              }
        "Net" {
                $VMNet = @(get-vm -name $ServerName | Get-VMNetworkAdapter)[0]
                Set-VMFirmware -VMName $ServerName -FirstBootDevice $VMNet
              }
        "HD"  {
                $HD = @(get-vm -name $ServerName | Get-VMHardDiskDrive)[0]
                Set-VMFirmware -VMName $ServerName -FirstBootDevice $HD
              }
        "File"{
                $VMFW = get-vmFirmware -VMName $ServerName | where {$_.BootOrder.BootType -eq "File"}
                if ($VMFW -ne $null)
                {
                    foreach ($bootType in $VMFW.BootOrder)
                    {
                        if ($bootType.BootType -eq "File")
                        {
                            $file = $bootType
                        }
                    }
                    if ($file -ne $null)
                    {
                        Set-VMFirmware -VMName $ServerName -FirstBootDevice $file
                    }
                }
                
              }
       Default {
                $DVD = @(get-vm -name $ServerName | Get-VMDvdDrive)[0]
                Set-VMFirmware -VMName $ServerName -FirstBootDevice $DVD
               }
                          }
    }
    if ($Gen -eq 1)
    {
        switch ($BootMode){
        "DVD" {
                Set-VMBios -VMName $ServerName -StartupOrder @(”CD”,“IDE”,”LegacyNetworkAdapter”,”Floppy”)
              }
        "Net" {
                Set-VMBios -VMName $ServerName -StartupOrder @(”NetworkAdapter”,”CD”,“IDE”,”Floppy”)
              }
        "HD"  {
                Set-VMBios -VMName $ServerName -StartupOrder @(“IDE”,”NetworkAdapter”,”CD”,”Floppy”)
              }
        "File"{
                #not supported in gen1, so using HD
                Set-VMBios -VMName $ServerName -StartupOrder @(“IDE”,”NetworkAdapter”,”CD”,”Floppy”)
              }
         Default {
                Set-VMBios -VMName $ServerName -StartupOrder @(”CD”,“IDE”,”LegacyNetworkAdapter”,”Floppy”)
              }                
                         
                         }
    }



}

function make_switch (
[string]$SwitchName,
[string]$switchType = "external", 
[string]$netAdapter = "wan"
)
{
    # this function takes in a switch name, type, and network adapter name 
    # and creates a switch. If the net name does not exist (or is hyper-v
    # switch type, it will use the first listed network adapter that is not 
    # the function creates the following output
    # switchName = the switch was either created or already existed
    # 0 = A switch name was not supplied
    # 1 = There are no available network adapters to create an external switch
    # 2 = This switch exists, but of another type, cannot create
    # 3 = The switch check function was supplied invalid data.  
      
    if ($switchName)
    {
        $IsSwitchNameUsed = Check_Switch_Status $switchName $SwitchType
        if ($IsSwitchNameUsed -eq 0)
        {
            switch ($switchType)
            {
                "external" {
                                if (!(Get-NetAdapter -Name $netAdapter -ErrorAction SilentlyContinue | where {$_.InterfaceDescription -notlike "*Hyper-V*"}))
                                {
                                    $netAdapter = ""
                                }
                                if (!($netAdapter)) 
                                {
                                    $net = Get-NetAdapter | where {$_.InterfaceDescription -notlike "*Hyper-V*"}
                                    $netAdapter = $net[0].Name
                                }
                                if ($netAdapter)
                                {
                                    New-VMSwitch -Name $SwitchName -AllowManagementOS $True -NetAdapterName $netAdapter
                                    $returnValue = $SwitchName
                                }
                                else 
                                {
                                    $returnValue = 1
                                }
                       
                            }
                "internal"   {
                                NEW-VMSWITCH –Name $SwitchName  –SwitchType internal
                                $returnValue = $SwitchName 
                           } 
                "private"  {
                                NEW-VMSWITCH –Name $SwitchName  –SwitchType Private
                                $returnValue = $SwitchName                    
                           } 
            }
        }
        if ($IsSwitchNameUsed -eq 1)
        {
            $returnValue = $SwitchName
        }
        if ($IsSwitchNameUsed -eq 2)
        {
            $returnValue = 2
        }
        if ($IsSwitchNameUsed -eq 3)
        {
            $returnValue = 3
        }
    }
    else
    {
        $returnValue = 0
    }

    return $returnValue
        
}

function Check_Switch_Status (
    [string]$SwitchName, 
    [string]$SwitchType
)
{
    #this function takes in a switch name and type and determines
    # 0 = This switch does not exist
    # 1 = This switch exists of tha type
    # 2 = This switch exists, but of another type  
    # 3 = You fail at inputting values. And your family should be ashamed
    $IsSwitchNameUsed = Get-VMSwitch -ErrorAction SilentlyContinue -Name $switchName
    if (!($IsSwitchNameUsed))
    {
        $returnValue = 0
    }
    else 
    {
        if ($IsSwitchNameUsed.SwitchType -eq $switchType)
        {
            $returnValue = 1
        }
        else 
        {
            $returnValue = 2
        }
    }
    if ((!($switchName)) -or (!($switchType)))
    {
        $returnValue = 3
    }
    return $returnValue
}

function Set_Dynamic_Ram (
    [string]$VMName, 
    [string]$MaxRam, 
    [string]$MinRam
)
{
    Set-VM -Name $VMName -DynamicMemory -MemoryMaximumBytes (Invoke-Expression $MaxRam) -MemoryMinimumBytes (Invoke-Expression $MinRam)
}

function Set_Processor (
    [string]$VMName, 
    [int]$procCount,
    [string]$MigrationCompatibility
    )
{
    if (($procCount) -and ($VMName))
    {
        if ($procCount.GetType().Name -eq "Int32")
        {
            Get-VM $VMName | Set-VMProcessor -Count $procCount
        }
    }
    if (($MigrationCompatibility) -and ($VMName))
    {
        if ($MigrationCompatibility -eq "True")
        {
            Get-VM $VMName | Set-VMProcessor -CompatibilityForMigrationEnabled 1
        }
        if ($MigrationCompatibility -eq "False")
        {
            Get-VM $VMName | Set-VMProcessor -CompatibilityForMigrationEnabled 0
        }
    }

}

#######################################################
# Import the XML File and assign variables
#######################################################
[xml]$Specs = Get-Content $XMLFile

if ($Specs.root.Gen)
{
    $gen = $Specs.root.gen
}
else
{
    $Gen = 2
}

if ($specs.root.RAM.Start)
{
    $StartRAM = $specs.root.RAM.Start
}
else
{
    $StartRAM = $StartRAMDefault
}

$ServerName = $Specs.root.VMName

#######################################################
# Create the directories needed for the VM And HD's
#######################################################
write-output ("Creating Directories")

if (!(Test-Path $location -ErrorAction SilentlyContinue))
{
    mkdir $location
}

$VMDirectory = write-output ($Location + "\" + $ServerName)

if (!(Test-Path $VMDirectory))
{
    mkdir $VMDirectory
}

if ($DiskDir.Contains(".\"))
{
    $DiskDir = $VMDirectory + $DiskDir.Remove(0,1)
}

if (!(Test-Path $DiskDir))
{
    mkdir $DiskDir
}


#######################################################
# Create the VM
#######################################################
write-output ("Creating the virtual Machine")

make_VM -serverName $Specs.root.VMName -RAM $StartRAM -Location $VMDirectory -Gen $Gen

#######################################################
# Create and add the HDs
#######################################################
write-output ("Creating and adding the Hard Disks")

if ($Specs.root.Disk)
{
    if ($Specs.root.Disk.Count -gt 1)
    {
        foreach ($disk in $Specs.root.Disk)
        {
            $DriveName = make_drive -ServerName $ServerName -DriveNumber $disk.label -DriveSize $Disk.size -driveType $disk.Type -DiskGen $disk.DiskGen -DiskDir $DiskDir
            if ($DriveName)
            {
                add_drive -ServerName $ServerName -DriveNumber $disk.label -DriveType $disk.Type -DiskDir $DiskDir -DiskGen $disk.DiskGen -DriveName $DriveName -controllerNo $disk.ControllerNo
            }
        }
    }
    else
    {
        $DriveName = make_drive -ServerName $ServerName -DriveNumber $Specs.root.Disk.label -DriveSize $Specs.root.Disk.size -driveType $Specs.root.Disk.Type -DiskGen $Specs.root.Disk.DiskGen -DiskDir $DiskDir -DriveName $DriveName 
        if ($DriveName)
        {
            add_drive -ServerName $ServerName -DriveNumber $Specs.root.Disk.label -DriveType $Specs.root.Disk.Type -DiskDir $DiskDir -DriveName $DriveName -DiskGen $Specs.root.Disk.DiskGen -controllerNo $Specs.root.Disk.ControllerNo
        }
    }  
}


#######################################################
# Create the switch
#######################################################
write-output ("Creating the switch")

$ActualSwitchName = make_switch $SwitchName -switchtype $Specs.root.Network.type -netAdapter $networkAdapter

#######################################################
# add network adapter
#######################################################
write-output ("Adding Network Adapters to VM")

if ($ActualSwitchName)
{
    if ($ActualSwitchName.GetType().Name -eq "String")
    {
        if (Get-VMNetworkAdapter -VMName $ServerName)
        {
            Get-VMNetworkAdapter -VMName $ServerName | Connect-VMNetworkAdapter -switchname $ActualSwitchName
        }
        else
        {
            ADD-VMNetworkAdapter -vmname $ServerName -switchname $ActualSwitchName
        }

    }
    else 
    {
        Write-output ("The network adapter was not added to the VM. The make_switch function returned " + $ActualSwitchName)
    }
}

######################################################
# Sets the processor count and compatibility mode
######################################################
write-output ("Setting Processor count and compatibility mode")

Set_Processor -VMName $ServerName -procCount $Specs.root.Processor.Count -MigrationCompatibility $Specs.root.Processor.Compatibility
   
######################################################
# Sets the Dynamic RAM Options if Warranted
######################################################
write-output ("Setting Dynamic Ram")

if ($Specs.root.RAM.Dynamic)
{
  Set_Dynamic_Ram -VMName $ServerName -MaxRam $Specs.root.RAM.Max -MinRam $Specs.root.Ram.Min
}

######################################################
# add the optical drive
######################################################
write-output ("Adding Optical Drives")

if ($CD_ISO)
{
    $CD = $CD_ISO
}
else 
{
    $CD = $Specs.root.CD.Source
}

if ($CD)
{
    if (Get-VMDvdDrive -VMName $ServerName)
    {
        Set-VMDvdDrive -VMName $ServerName -Path $CD
    }
    else
    {
        $OpticalAdd = add_optical $serverName $CD
    }
}

######################################################
# Sets the boot move of the vm
######################################################
write-output ("Setting Boot Mode")

set_boot $ServerName $specs.root.boot $gen


Start-VM $ServerName 
