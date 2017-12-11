
function Generate_File_Name (
    [string]$outputDirectory,
    [string]$FileName
)
{
    if ($fileName)
    {
        if ($filename.Contains(":"))
        {
            if (Test-Path $filename.Substring(0, $filename.IndexOf(":")+1))
            {
                if (test-path $filename.Substring(0, $filename.Lastindexof("\"+1)))
                {

                }
            }
                
        }

}


function GET_Counters (
 $counters = @("\LogicalDisk(E:)\Disk Bytes/sec", "\LogicalDisk(C:)\Disk Bytes/sec", "\LogicalDisk(D:)\Disk Bytes/sec", "\LogicalDisk(F:)\Disk Bytes/sec"),
 $counterFile,
 $servername, 
 $sample_interval= 5,
 $MaxSamples = 17280, 
 $outputDirectory = "F:\ServerSpecTest_20170627",
 $FileName 
)
{
get-counter -Counter $counters -SampleInterval $sample_interval -MaxSamples 345600 | export-counter -Path "F:\ServerSpecTest_20170627\DriveBytesSec_E_20170629_20170630.blg"
#get-counter "\PhysicalDisk(0 C:)\% Idle Time", "\PhysicalDisk(1 E:)\% Idle Time" -SampleInterval 5 -MaxSamples 12

}