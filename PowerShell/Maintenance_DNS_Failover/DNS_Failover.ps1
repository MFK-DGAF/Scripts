$Zone = "rhadata.rushhealthassociates.com"
$DC1 = "DonkeyKong"
$DC2 = "Bowser"

$PingRequest = Test-Connection -ComputerName testytest -Count 6 -Quiet
if ($PingRequest -eq $false)
{
    $OldObj = Get-DnsServerResourceRecord -Name "ActiveDC" -ZoneName $Zone -RRType "A"
    $NewObj.RecordData.IPv4Address = [System.Net.IPAddress]::parse('10.1.4.40')
    $NewObj.TimeToLive = [System.TimeSpan]::FromHours(2)
    Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $Zone -PassThru
}