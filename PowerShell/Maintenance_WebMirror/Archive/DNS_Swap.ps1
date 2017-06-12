$Script = {
get-dnsServerResourceRecord -ZoneName $args[0] -Name $args[1] | where-object {$_.RecordType -eq "A" } 
}

$set_DNS_entry_Script = {
Set-DnsServerResourceRecord -NewInputObject $args[0] -OldInputObject $args[1] -ZoneName $args[2] -PassThru
}

$DNSServer = "Bowser"
$ZoneName = "RHADATA.rushhealthassociates.com"
$hostname = "tom"

$oldDNSRecord = invoke-command -ComputerName $DNSServer -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
if ($oldDNSRecord.RecordData.IPv4Address -eq "10.1.4.10")
{
    $address = "10.1.4.9"
}
elseif ($oldDNSRecord.RecordData.IPv4Address -eq "10.1.4.9")
{
    $address = "10.1.4.10"
}


$NewDNSRecord = invoke-command -ComputerName $DNSServer -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
$NewDNSRecord.RecordData.IPv4Address = $address

invoke-command -ComputerName $DNSServer -ScriptBlock $set_DNS_entry_Script -ArgumentList $NewDNSRecord, $OldDNSRecord, $ZoneName


