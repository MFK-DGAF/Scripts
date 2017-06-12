param(
    [string]$hostname,
    [string]$server1, 
    [string]$server2, 
    [string]$KeyDB,
    [string]$smtpServer, 
    [string]$notify,
    $webServers = ("Cheech", "Chong", "Koopa", "Mario-ExtWeb", "Luigi-ExtWeb", "Yoshi-ExtWeb"),
    $dnsServers = ("Bowser", "DonkeyKong", "Luigi-spadfs2")
    )


function update_DNS_Records(
    $DNSServers = ("Bowser", "DonkeyKong","Luigi-spadfs2"),
    $ZoneName = "RHADATA.rushhealthassociates.com",
    $hostname = "tom",
    $Address
    )
{
    ######################################################################
    # Declare Scripts
    ######################################################################
    
    #Script to Query for the existing DNS record ###
    $Script = {
            get-dnsServerResourceRecord -ZoneName $args[0] -Name $args[1] | where-object {$_.RecordType -eq "A" } 
        }
    
    #Script to updatet a dns record ###
    $set_DNS_entry_Script = {
            Set-DnsServerResourceRecord -NewInputObject $args[0] -OldInputObject $args[1] -ZoneName $args[2] -PassThru
        }
    
    ###script to add a new dns entry ####
    $add_DNS_entry_Script = {
        Add-DnsServerResourceRecordA -Name $args[0] -ZoneName $args[1] -AllowUpdateAny -IPv4Address $args[2] -TimeToLive 0:01:00
    }

    #####################################################################
    # execute dns flush   
    #####################################################################

    if ($DNSServers.count -gt 1)
    {
        $oldDNSRecord = invoke-command -ComputerName $DNSServers[0] -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
        $NewDNSRecord = invoke-command -ComputerName $DNSServers[0] -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
        $NewDNSRecord.RecordData.IPv4Address = $address
        foreach ($Server in $DNSServers)
        {
            invoke-command -ComputerName $Server -ScriptBlock $set_DNS_entry_Script -ArgumentList $NewDNSRecord, $OldDNSRecord, $ZoneName
        }
    }
    else
    {
        $oldDNSRecord = invoke-command -ComputerName $DNSServers -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
        $NewDNSRecord = invoke-command -ComputerName $DNSServers -ScriptBlock $Script -ArgumentList $ZoneName, $hostname
        $NewDNSRecord.RecordData.IPv4Address = $address
        invoke-command -ComputerName $DNSServers -ScriptBlock $set_DNS_entry_Script -ArgumentList $NewDNSRecord, $OldDNSRecord, $ZoneName
    }
    
    #################################################################################################################################
    #invoke-command -ComputerName $DNSServer -ScriptBlock $add_DNS_entry_Script -ArgumentList $hostname, $ZoneName, $address
}

function get_Max_Address(
    $Addresses,
    [switch]$getmin
    )
{
    #Gets the address out of an array with the lowest subnet value
    # ie. 10.1.4.1 > 10.1.200.1
    # returns the lowest, unless the -getmin flag is specified
    if ($getmin)
    {
        foreach ($address in $Addresses)
        {
            if (($address -lt $maxAddress) -or (!($maxAddress)))
            {
                $maxAddress = $address
            }
        }
    }
    else
    {
        foreach ($address in $Addresses)
        {
            if (($address -gt $maxAddress) -or (!($maxAddress)))
            {
                $maxAddress = $address
            }
        }
    }
    return $maxAddress
}


function Test_HostName (
    [string]$hostName = "tom",
    [string]$Server1 = "ginger",
    [string]$Server2 = "maryann",
    [string]$KeyDB = "RHA"
    )
{
###Test if the Key Database is running as primary (or alone) on the server. 
##if it's primary or unmirrored, return 1
##if it's not, test the other ip address
##if it's running as primary or unmirrored on the second server, return the new ip address
##if it's not running as primary or unmirrored on either server, return 0

$currentAddress = [System.Net.Dns]::GetHostAddresses($hostName).IPAddressToString
$Server1Address = [System.Net.Dns]::GetHostAddresses($Server1).IPAddressToString
$Server2Address = [System.Net.Dns]::GetHostAddresses($Server2).IPAddressToString
$Test_Host_Primary = Test_KeyDB -hostname $currentAddress

foreach ($address1 in $Server1Address)
{
    if (($address1 -gt $maxAddress1) -or ($maxAddress1 -eq $null))
    {
        $maxAddress1 = $address1
    }
}

foreach ($address2 in $Server2Address)
{
    if (($address2 -gt $maxAddress2) -or ($maxAddress2 -eq $null))
    {
        $maxAddress2 = $address2  
    }
}

if ($Test_Host_Primary -eq 0)
{
    if (($currentAddress -eq $maxAddress1) -and ($currentAddress -ne $maxAddress2))
    {
        $NewAddress = $maxAddress2 
        $NewHost = $Server2
    }
    if (($currentAddress -eq $maxAddress2) -and ($currentAddress -ne $maxAddress1))
    {
        $NewAddress = $maxAddress1
        $NewHost = $Server1
    }
    if ($NewAddress -ne $Null)
    {
        #Check to ensure that the DB is primary on second server
        $Test_Host_New = Test_KeyDB -hostname $NewHost
    }
    if (($Test_Host_New -eq 0) -or ($NewAddress -eq $Null))
    {
        #Both Addresses are hosed
        $returnValue = 0
    }
    else 
    {
        #New Primary DB
        $returnValue = $newAddress
    }
}
else
{
    $returnValue = 1
} 

Return $ReturnValue
}

function Test_KeyDB (
    [string]$hostname,
    [string]$KeyDB = "RHA"
)
{
    ##Import SQL Modules
    if (-not(Get-Module -Name SQLPS) -and (-not(Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -ErrorAction SilentlyContinue))) 
    {
        if (Get-Module -Name SQLPS -ListAvailable) 
        {
            if ((Get-ExecutionPolicy) -ne 'Restricted')
            {
                Import-Module -Name SQLPS -DisableNameChecking
            } 
        }
        elseif (Get-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100 -Registered -ErrorAction SilentlyContinue) 
        {
            Add-PSSnapin -Name SqlServerCmdletSnapin100, SqlServerProviderSnapin100
        }            
    }

     
    $DBListText = write-output ("SQLSERVER:\SQL\" + $hostname + "\DEFAULT\DATABASES")
    $DBList = dir $DBListText | Select-Object name, Status | Where {$_.Name -eq  $KeyDB}


    if (($DBList.Name -eq $KeyDB) -and ($DBList.Status -eq "Normal"))
    {
        $returnValue = 1
    }
    else 
    {
        $returnValue = 0
    }

    return $returnValue

}


function Flush_DNS (
    $FlushServers = ("Hermes", "Cheech", "Chong")
    )
{
    foreach ($web in $FlushServers)
    {
        if (test-Connection -ComputerName $web -Count 2 -Quiet )
        {
            invoke-command -ComputerName $web -ScriptBlock {ipconfig /flushdns}
        }
    }
}

function DNS_Updater (
    $hostname, 
    $server1 = "ginger",
    $server2 = "maryann", 
    $KeyDB = "RHA", 
    $smtpServer = "cheech", 
    $emailRecipient = "Alerts@rush-health.com", 
    $webServers = ("cheech","chong", "mario-extweb", "luigi-extweb", "yoshi-extweb")
    )
{
    $HostTest = Test_HostName -hostName $hostName -Server1 $server1 -Server2 $Server2 -KeyDB $KeyDB
    if (($hostTest -ne 0) -and ($hostTest -ne 1))
    {
        if (test-Connection -ComputerName $HostTest -Count 2 -Quiet )
        {
            update_DNS_Records -Address $HostTest -hostname $hostName
            $emailMessage = write-output ("The IP Address for the DNS entry " + $hostName + " has been updated to " + $HostTest)
            $messageSubject = "DB DNS failover"
            Flush_DNS $webServers
        }
        else 
        {
            $emailMessage = Write-output ("There was a problem connecting to the database on " + $hostName + " but the DNS service was unable to communicate with the failover at " + $hosttest + ". Please investigate.")
            $messageSubject = "Error during DB DNS failover"
        }
    }
    else
    {
        if ($hostTest -eq 0)
        {
            $emailMessage = write-output ("There was a problem connecting to the datbase on " + $hostName + ". Please check on the status of the mirroring.")
            $messageSubject = "Error during DB DNS failover" 
        }
    }

    if ($emailMessage)
    {
        $smtpFrom = "DBMirror@rush-health.com"
        $body = $emailMessage
        $smtpTo = $emailRecipient
        send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -BodyAsHtml -smtpServer "$smtpserver"	
    }

}


DNS_Updater -hostname $hostname -server1 $Server1 -server2 $Server2 -KeyDB $KeyDB -smtpServer $smtpServer -emailRecipient $notify -webServers $WebServers