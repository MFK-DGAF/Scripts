param ( 
    [string] $filename = "C:\Users\tspooner\Documents\Workspace_DriveUsageAuditing\pmmc\DriveBytesSec_E_20170629_20170630.blg" ,
    [int] $reportingInterval = 60
)

$list = import-counter $filename
[double[]]$TotalAmount
[double[]]$MaxValue
[double[]]$AverageAmount

$CounterCount = $list[0].CounterSamples.count
$MasterList = new- object system.collections.arraylist
#$device1 = new-object -TypeName "PSObject" -Prop (@{'Name'= "RHBak01"; 'IP'="10.121.38.23"})
$started = 0
$count = 0

foreach ($item in $list)
{
    if (!$Started)
    {
        if ($item.TimeStamp.Second -eq 0)
        {
            $Started = 1
            #initializes $driveThroughput array
            $AverageAmount = @(0) * $item.CounterSamples.Count
            $DriveThroughput = @(0) * $item.CounterSamples.Count
        }
    }
    if ($Started)
    {
        if (!$start_time)
        {
            $start_time = $item.TimeStamp
        }
        
        if ($item.TimeStamp -lt $start_time.AddSeconds($reportingInterval))
        {
            $objectCount = $item.CounterSamples.Count
            $intervalCount++
            $TotalCount++     
                  
            for ($i = 0; $i -lt $objectCount; $i++)
            {
                   $DriveThroughput[$i] += $item.CounterSamples[$i].CookedValue
            }
        }
        if ($item.TimeStamp -ge $start_time.AddSeconds($reportingInterval))
        {
            $reportItem = new-object -TypeName "PSObject"
            Add-Member -InputObject $reportItem "Start Time" $start_time
            for ($i = 0; $i -lt $objectCount; $i++)
            {
                   $TotalThroughput += $DriveThroughput[$i]
                   $AverageAmount[$i] = [math]::Round((($DriveThroughput[$i]/$intervalcount)/1048576),4)
                   $fieldName = Write-Output ($item.CounterSamples[$i].InstanceName + " MB/s")
                   Add-Member -InputObject $reportItem $fieldName $AverageAmount[$i]
            }
            $AVGTotal = [math]::Round((($TotalThroughput/$intervalcount)/1048576),4)
            Add-Member -InputObject $reportItem "Total" $AVGTotal

            #$reportItem = new-object -TypeName "PSObject" -Prop (@{'StartTime'=$start_time; 'Throughput MB/s'= [math]::Round(($AverageAmount/1048576),4)})
            #wipes DriveThroughput Array
            $DriveThroughput = @(0) * $item.CounterSamples.Count
            $TotalThroughput = 0
            $MasterList.Add($reportItem)
            $start_time = $item.TimeStamp
            $intervalcount = 1
            for ($i = 0; $i -lt $objectCount; $i++)
            {
                $DriveThroughput[$i] = $item.CounterSamples[$i].CookedValue
            }
        }
    }
}


$MasterList | where {$_.Total -gt 1}





#$counters = @("\LogicalDisk(E:)\Disk Bytes/sec", "\LogicalDisk(C:)\Disk Bytes/sec", "\LogicalDisk(D:)\Disk Bytes/sec", "\LogicalDisk(F:)\Disk Bytes/sec")
#get-counter -Counter $counters -MaxSamples 345600 | export-counter -Path "F:\ServerSpecTest_20170627\DriveBytesSec_E_20170629_20170630.blg"
#get-counter "\PhysicalDisk(0 C:)\% Idle Time", "\PhysicalDisk(1 E:)\% Idle Time" -SampleInterval 5 -MaxSamples 12
#Get-WmiObject -class "Win32_systemslot"




# Get the model of the computer
#(Get-WmiObject -Class:Win32_ComputerSystem).Model

# Get the list of possible drive counters
# get-counter -ListSet physicaldisk|select -expand counter

#site on perfmon powershell counters
#http://www.computerperformance.co.uk/powershell/powershell_perfmon.htm

#get list of wmipnp devices
#get-wmiobject win32_Pnpentity

#get list of disks?
#gets deviceID of controller
#get-wmiobject Win32_DiskDrive

#Get scsi controller
#get-wmiobject win32_ScsiController

# Get list of PCIe slots and data width
# Get-Wmiobject win32_SystemSlot 

#original doc which led me to SetupAPI
#https://www.naraeon.net/en/pci-express-linkwidth-linkspeed/


#pinvoke struct for SP_DEVINFO_DATA
#http://www.pinvoke.net/default.aspx/Structures.SP_DEVINFO_DATA
#pinvoke struct for DEVPROPKEY
#http://www.pinvoke.net/default.aspx/Structures.DEVPROPKEY
#pinvoke for SetupDiGetDeviceProperty
#http://www.pinvoke.net/default.aspx/setupapi.SetupDiGetDeviceProperty
#msdn for SetupDiGetDeviceProperty
#https://msdn.microsoft.com/en-us/library/windows/hardware/ff551963(v=vs.85).aspx




($cp = new-object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe' 

$deviceFunction = @"
[StructLayout(LayoutKind.Sequential)]
public unsafe struct DEVPROPKEY
{
    public Guid fmtid;
    public UInt32 pid;
}
[StructLayout(LayoutKind.Sequential)]
public struct SP_DEVINFO_DATA
{
   public uint cbSize;
   public Guid classGuid;
   public uint devInst;
   public IntPtr reserved;
}
[DllImport("Setupapi.dll", EntryPoint="SetupDiGetDeviceProperty", CallingConvention=CallingConvention.StdCall)]
    public static extern unsafe bool SetupDiGetDevicePropertyW(
        IntPtr deviceInfoSet,
        ref SP_DEVINFO_DATA DeviceInfoData, 
        ref DEVPROPKEY propertyKey,
        out UInt64 propertyType, // or Uint32 ?
        IntPtr propertyBuffer, // or byte[] 
        Int32 propertyBufferSize,
        out int requiredSize, // <---- 
        UInt32 flags);
"@

#$SetupAPI = Add-Type -MemberDefinition $deviceFunction -Name SetupAPI -Namespace Win32 -CompilerParameters $CP -PassThru 

#$SetupAPI::SetupDiGetDeviceProperty


