param ( 
    [string] $filename = "F:\ServerSpectTest_20170627\DriveBytesSec_E_20170628_20170629.blg" ,
    [int] $reportingInterval = 12
)

$list = import-counter $filename
[double]$TotalAmount
[double]$MaxValue
[double]$AverageAmount

$CounterCount = $list[0].CounterSamples.count
$MasterList = new-object system.collections.arraylist
#$device1 = new-object -TypeName "PSObject" -Prop (@{'Name'= "RHBak01"; 'IP'="10.121.38.23"})

foreach ($item in $list)
{
    if ($item.CounterSamples[0].CookedValue -ne 0)
    {
        if ($MaxValue -lt $item.CounterSamples[0].CookedValue)
        {
            $MaxValue = $item.CounterSamples[0].CookedValue
        }
        if ($RangeBegin -eq $null)
        {
            $RangeBegin = $item.TimeStamp
        }
        $TotalAmount += $item.CounterSamples[0].CookedValue
        $AmountCount ++
        $time = $item.TimeStamp
        
    }
    else
    {
        if ($MaxValue -ne $null)
        {
             $AverageAmount = $TotalAmount/$AmountCount
             $RangeEnd = $time
             $ListItem = new-object -TypeName "PSObject" -Prop (@{'StartTime'= $RangeBegin; 'EndTime'=$RangeEnd; 'Average'= $AverageAmount; 'Max'=$MaxValue})
             $MasterList += $ListItem
             #wipe the variables
             $MaxValue = $null
             $RangeBegin = $null
             $rangeEnd = $null
             $AmountCount = $null
        }   

    }
  
}
if ($MaxValue -ne $null)
{
    $AverageAmount = $TotalAmount/$AmountCount
    $RangeEnd = $time
    $ListItem = new-object -TypeName "PSObject" -Prop (@{'StartTime'= $RangeBegin; 'EndTime'=$RangeEnd; 'Average'= $AverageAmount; 'Max'=$MaxValue})
    $MasterList += $ListItem
    #wipe the variables
    $MaxValue = $null
    $RangeBegin = $null
    $rangeEnd = $null
}

$MasterList





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

#get list of disks?
#gets deviceID of controller
#get-wmiobject Win32_DiskDrive

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

$SetupAPI = Add-Type -MemberDefinition $deviceFunction -Name SetupAPI -Namespace Win32 -CompilerParameters $CP -PassThru 

$SetupAPI::SetupDiGetDeviceProperty


$signature = @"
[DllImport("Setupapi.dll", EntryPoint="InstallHinfSection", CallingConvention=CallingConvention.StdCall)]
public static extern void InstallHinfSection(
    [In] IntPtr hwnd,
    [In] IntPtr ModuleHandle,
    [In, MarshalAs(UnmanagedType.LPWStr)] string CmdLineBuffer,
    int nCmdShow);
"@

$InstallHinfSection = Add-Type -MemberDefinition $signature -UsingNamespace System.Runtime.InteropServices -Name Win32SInstallHinfSection -Namespace Win32Functions  -PassThru 