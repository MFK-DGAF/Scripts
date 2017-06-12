$Date = Read-Host "Please Enter The Date Using Format XX/XX/XXXX"
$Time = Read-Host "Please Enter The Time Using Format XX:XX AM/PM"
Set-Date -date "$Date $Time"