
param(
    [string]$hostname = "tom",
    [string]$server1 = "ginger", 
    [string]$server2 = "maryann", 
    [string]$KeyDB = "RHA",
    [string]$smtpServer = "Cheech", 
    [string]$notify = "Torsten_Spooner@rush.edu",
    $webServers = ("Cheech", "Chong", "Koopa", "Mario-ExtWeb", "Luigi-ExtWeb", "Yoshi-ExtWeb"),
    $dnsServers = ("Bowser", "DonkeyKong", "Luigi-spadfs2")
    )




DNS_Updater -hostname $hostname -server1 $Server1 -server2 $Server2 -KeyDB $KeyDB -smtpServer $smtpServer -emailRecipient $notify -webServers $WebServers