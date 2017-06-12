 Param(
    $hostnames = ("jerry", "ActiveWebDB"),
    [string]$server1 = "ginger",
    [string]$server2 = "maryann",
    [string]$KeyDB = "RHA",
    [string]$DBListFile = "E:\automation\Maintenance_WebMirror\DBList.txt",
    [string]$smtpServer = "cheech",
    [string]$notify = "alerts@rush-health.com", 
    $webServers = ("Cheech", "Chong", "Koopa", "Mario-ExtWeb", "Luigi-ExtWeb", "Yoshi-ExtWeb"),
    $dnsServers = ("Bowser", "DonkeyKong", "Luigi-spadfs2")
    )
############################################################
# Service (soon to be) that checks if the Key DB matches the 
# DNS entry(s) that point to the DB Server. 
# it also checks if the DB's that are mirrored (or appear 
# to have been mirrored)
############################################################

. "E:\automation\Maintenance_WebMirror\Mirror_Functions.ps1"
. "E:\automation\Maintenance_WebMirror\Mirror_Guard_Functions.ps1"
. "E:\automation\Maintenance_WebMirror\DNS_Update_Functions.ps1"

$count = 0
foreach ($hosty in $hostnames)
{
    if ($count -eq 0)
    {
        CHECK_MIRROR_MAIN $hosty $server1 $server2 $KeyDB $DBListFile $notify $smtpServer
    }
    $returncount = DNS_Updater -hostname $hosty -server1 $Server1 -server2 $Server2 -KeyDB $KeyDB -smtpServer $smtpServer -emailRecipient $notify -webServers $WebServers
    $count++
}




