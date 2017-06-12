function GET_SERVER_LIST ([string]$SQLServer = $env:COMPUTERNAME, [string]$DBName = "Maintenance_Support", [string]$Domain = "")
{

    $sourceDir = (Get-Item -Path ".\" -Verbose).FullName
    import-module sqlps -DisableNameChecking

$List_Servers_Query= 
@"
Select ServerName as Name, ScriptDir, Domain from [Scripts].[Server] where domain like `$(DomainName)
"@

    $Param = "DomainName='%" + $Domain + "%'"
    $Results = invoke-sqlcmd -ServerInstance $SQLServer -Database $DBName -Query $List_Servers_Query -Variable $Param
    cd $sourceDir
    return $Results

}



function GET_SERVER_INFO ([string]$ServerName, [string]$SQLServer = $env:COMPUTERNAME, [string]$DBName = "Maintenance_Support")
{

    $sourceDir = (Get-Item -Path ".\" -Verbose).FullName
    import-module sqlps -DisableNameChecking

$List_Servers_Query= 
@"
Select ServerName as Name, ScriptDir, Domain from [Scripts].[Server] where ServerName like `$(ServerName)
"@

    $Param = "ServerName='%" + $ServerName + "%'"
    $Results = invoke-sqlcmd -ServerInstance $SQLServer -Database $DBName -Query $List_Servers_Query -Variable $Param
    cd $sourceDir
    return $Results

}