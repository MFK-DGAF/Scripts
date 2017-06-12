$TimeZone = "Central Standard Time"

$process = New-Object System.Diagnostics.Process 
  $process.StartInfo.WindowStyle = "Hidden" 
  $process.StartInfo.FileName = "tzutil.exe" 
  $process.StartInfo.Arguments = "/s `"$TimeZone`"" 
  $process.Start() | Out-Null 