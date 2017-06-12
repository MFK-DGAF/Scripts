##################################
#Directly provide the server name#
##################################

[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.Smo”) |Out-Null

$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server(“MARIO-SPDB1”)

$SqlServerSec = New-Object Microsoft.SqlServer.Management.Smo.Server(“LUIGI-SPDB1”)

$SqlServer.AvailabilityGroups[“SharePoint”].AvailabilityReplicas | Select-Object Name, Role

#################################################################################################

######################
#Pull the server name#
######################

$ServerName = $env:COMPUTERNAME

[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.Smo”) |Out-Null

$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server("$ServerName")

#$SqlServerSec = New-Object Microsoft.SqlServer.Management.Smo.Server(“LUIGI-SPDB1”)

$SqlServer.AvailabilityGroups[“SharePoint”].AvailabilityReplicas | Select-Object Name, Role