Push-Location

Set-Location HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters

$value = Read-Host "Please Set The Description For This System"

Set-ItemProperty . srvcomment “$value”

Pop-Location
