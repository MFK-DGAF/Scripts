param(
[string]$outputDir = "C:\Temp",
$WarnThreshold = 45, 
$FailedThreshold = 10
)

$ServerMem = Get-Ciminstance Win32_OperatingSystem
$PctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

$ServerStatus = "OK"
$ServerMessage = ""
$ServerMemMessage = ""

$ServerFile = write-output ($outputDir + "\MemCheck2-" + $env:COMPUTERNAME + ".html")

 


#$os = Get-Ciminstance Win32_OperatingSystem
#$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
 
if ($PctFree -le $FailedThreshold) {
$ServerStatus = "Failed"
}
elseif ($PctFree -le $WarnThreshold ) {
$ServerStatus = "Warning"
}
else {
$ServerStatus = "OK"
}
 
$ServerMem | Select @{Name = "Status";Expression = {$ServerStatus}},
@{Name = "PctFree"; Expression = {$PctFree}},
@{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
@{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}
 
  ##Declare the color variables
$red=@"
<font color="red"><b>
"@

$end=@"
</b></font>
"@

$yellow=@"
<font color="#FFCC33"><b>
"@

$Warn=@"
[<font color="#FFCC33"><b>Warning</b></font>]<br>
"@

$Fail=@"
[<font color="red"><b>FAILED</b></font>]<br>
"@

$OK=@"
[<font color="#66FF33"><b>OK</b></font>]<br>
"@
 
if ($ServerStatus -eq "Warning") {$ServerStatusText = $Warn}
if ($ServerStatus -eq "Failed") {$ServerStatusText = $Fail}
if ($ServerStatus -eq "OK") {$ServerStatusText = $OK}

if ($ServerStatus -eq "OK"){ $ServerMessage = write-output ("<b>Memory Check</b><br>") ("Status:              " + $ServerStatusText)}
if ($ServerStatus -ne "OK"){ $ServerMessage = write-output ("<b>Memory Check</b><br>") ("Status:          " + $ServerStatusText) $ServerMemMessage}

$ServerMessage | Set-Content -Path $ServerFile
