param(
$DestServerName = $env:COMPUTERNAME,
$DBName = "RHA_ACCOUNTABLE_CARE_MART_QA",
$AuditDBName = "RHA_AUDIT",
$AuditDBServerName = $env:COMPUTERNAME,
$BatchNumber = 1
)
$runDir = (Get-Location).Path
##########################################
# import SQL module
##########################################
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
cd $runDir


##All the permissions that are not connect
$AllDBPerms = "ALTER", "Alter any application role", "Alter any assembly", "Alter any asymmetric key", "Alter any certificate","Alter any contract", "Alter any database audit", "Alter any database DDL trigger", "Alter any database event notification", "Alter any dataspace", "Alter any fulltext catalog", "Alter any message type", "Alter any remote service binding", "Alter any role", "Alter any route", "Alter any schema", "Alter any service", "Alter any symmetric key", "Alter any user", "Alter", "Authenticate", "Backup database", "Backup log", "Checkpoint", "Connect", "Connect Replication", "Control", "Create aggregate", "Create assembly", "Create asymmetric key", "Create certificate", "Create contract", "Create database DDL event notification", "Create default", "Create fulltext catalog", "Create function", "Create message type", "Create procedure", "Create queue", "Create remote service binding", "Create role", "Create route", "Create rule", "Create schema", "Create service", "Create symmetric key", "Create synonym", "Create table", "Create type", "Create view", "Create XML schema collection", "Delete", "Execute", "Insert", "References", "Select", "Show Plan", "Subscribe query notifications", "Take ownership", "Update", "View database state", "View definition" 
$AllTablePerms = "SELECT", "INSERT", "REFERENCES", "TAKE OWNERSHIP", "UPDATE", "VIEW CHANGE TRACKING", "VIEW DEFINITION", "ALTER", "CONTROL", "EXECUTE"
$AllSchemaPerms = "ALTER", "CONTROL", "CREATE SEQUENCE", "DELETE", "EXECUTE", "INSERT", "REFERENCES", "SELECT", "TAKE OWNERSHIP", "UPDATE", "VIEW CHANGE TRACKING", "VIEW DEFINITION"
######################################################
# $UserGroupQuery gets list of group memeberships
# $UserPermissionsQuery gets all explicit permissions
######################################################
$UserGroupQuery=@"
SELECT [BatchNumber]
      ,[Database_Name]
      ,[GroupName]
      ,[UserName]
      ,[RunDate]
  FROM [RHA_AUDIT].[rha_dbPermissions].[GroupMembership]
  WHERE [BatchNumber] = `$(BatchNo)
  GO
"@

$UserPermissionsQuery=@"
SELECT [BatchNumber]
      ,[Database_Name]
      ,[Object_Type]
      ,[Grantor_User_Type]
      ,[Grantor]
      ,[Grantee_User_Type]
      ,[Grantee]
      ,[permission_name]
      ,[state_desc]
      ,[schema_name]
      ,[table_name]
      ,[RunDate]
  FROM [RHA_AUDIT].[rha_dbPermissions].[UserPermissions]
  WHERE [BatchNumber] = `$(BatchNo)
  GO
"@

$Group_Param = "BatchNo=" + $BatchNumber
$Perm_Param = "BatchNo=" + $BatchNumber
$groupparams = $Group_Param
$permparams = $Perm_Param

##Populates Arrays using SQL Queries above
$UserGroupList = invoke-sqlcmd -ServerInstance $AuditDBServerName -Database $AuditDBName -Query $UserGroupQuery -Variable $groupparams
$UserPermissionsList = invoke-sqlcmd -ServerInstance $AuditDBServerName -Database $AuditDBName -Query $UserPermissionsQuery -Variable $permparams

###############################################
##loop through the entries in the permissions
##table and do the right action based on that 
###############################################

########################################
##Declare all the queries!

##Explicit Rights Queries
$DropExistingUser=@"
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'`$(UName)')
DROP USER [`$(UName)]
GO
"@

$AddUser=@"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'`$(UName)')
CREATE USER [`$(UName)] FOR LOGIN [`$(UName)]
"@

$GrantRights=@"
`$(TheAction) `$(ThePower) TO [`$(TheDude)]
GO
"@

$GrantRightsOnObject=@"
`$(TheAction) `$(ThePower) ON `$(TheSchema).`$(TheThing) TO [`$(TheDude)]
GO
"@

$GrantRightsOnSchema=@"
`$(TheAction) `$(ThePower) ON SCHEMA::`$(TheSchema) TO [`$(TheDude)]
GO
"@

$GrantWithRights=@"
GRANT `$(ThePower) TO [`$(TheDude)] WITH GRANT OPTION 
"@

$GrantWithRightsOnObject=@"
GRANT `$(ThePower) ON `$(TheSchema).`$(TheThing) TO [`$(TheDude)] WITH GRANT OPTION 
"@

$GrantWithRightsOnSchema=@"
GRANT `$(ThePower) ON SCHEMA::`$(TheSchema) TO [`$(TheDude)] WITH GRANT OPTION 
"@

##group membership queries
$AddMemberToRole=@"
ALTER ROLE `$(TheGroup) ADD MEMBER [`$(TheDude)]
"@


#########################################################################
##Run all the Expicit permission queries!!


foreach ($UserPermission in $UserPermissionsList) 
{
    $LoopDBName = $UserPermission.Database_Name
    switch($UserPermission.Object_Type)
    {
        "DATABASE" {
                    #for permissions that are of the database, scope, this sorts through the 
                    switch($UserPermission.permission_name)
                        {
                        "CONNECT"{
                                  #The Connect Statements remove all the users before re-adding them
                                  #this should tie the DB Account to the server object
                                  #Additional logic should be added to verify the user has a server login
                                  $DropParam = "UName=" + $UserPermission.Grantee
                                  $AddParam = "UName=" + $UserPermission.Grantee
                                  $LoopDBName = "testing"
                                  $DropParam = "UName=" + "rmanager"
                                  $AddParam = "UName=" + "rmanager"
                                  invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $DropExistingUser -Variable $DropParam
                                  invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $AddUser -Variable $AddParam
                                 }
                        {$AllDBPerms -contains $_}
                                 {
                                 If (($UserPermission.state_desc -match "DENY") -or ($UserPermission.state_desc -match "GRANT"))
                                    {
                                    $ActionParam = "TheAction=" + $UserPermission.state_desc
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $ParamArray = $ActionParam, $PowerParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantRights -Variable $ParamArray
                                    }
                                 If ($UserPermission.state_desc -match "GRANT_WITH_GRANT_OPTION")
                                    {
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $ThingParam = "TheThing=" + $UserPermission.table_name
                                    $ParamArray =  $PowerParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantWithRights -Variable $ParamArray
                                    }
                                 }
                        default {write-host ("This option has not been added to the Database permissions script. Option = " + $UserPermission.permission_name)}
                         }
                    } #closes databse case
         "OBJECT_OR_COLUMN" {
                             #first if checks if permission is valid
                             If ( $AllTablePerms -contains $UserPermission.permission_name)
                                {
                                If (($UserPermission.state_desc -match "DENY") -or ($UserPermission.state_desc -match "GRANT"))
                                    {
                                    $ActionParam = "TheAction=" + $UserPermission.state_desc
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $ThingParam = "TheThing=" + $UserPermission.table_name
                                    $SchemaParam = "TheSchema=" + $UserPermission.schema_name
                                    $ParamArray = $ActionParam, $SchemaParam, $ThingParam, $PowerParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantRightsOnObject -Variable $ParamArray
                                    }
                                If ($UserPermission.state_desc -match "GRANT_WITH_GRANT_OPTION")
                                    {
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $ThingParam = "TheThing=" + $UserPermission.table_name
                                    $SchemaParam = "TheSchema=" + $UserPermission.schema_name
                                    $ParamArray =  $PowerParam, $SchemaParam, $ThingParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantWithRightsOnObject -Variable $ParamArray
                                    }
                                }
                            } #closes object case
        
         "SCHEMA" {
                            #first check if permission is valid
                            IF ( $AllSchemaPerms -contains $UserPermission.permission_name)
                                {
                                If (($UserPermission.state_desc -match "DENY") -or ($UserPermission.state_desc -match "GRANT"))
                                    {
                                    $ActionParam = "TheAction=" + $UserPermission.state_desc
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $SchemaParam = "TheSchema=" + $UserPermission.schema_name
                                    $ParamArray = $ActionParam, $SchemaParam, $PowerParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantRightsOnSchema -Variable $ParamArray
                                    }
                                If ($UserPermission.state_desc -match "GRANT_WITH_GRANT_OPTION")
                                    {
                                    $PowerParam = "ThePower=" + $UserPermission.permission_name
                                    $DudeParam = "TheDude=" + $UserPermission.Grantee
                                    $SchemaParam = "TheSchema=" + $UserPermission.schema_name
                                    $ParamArray =  $PowerParam, $SchemaParam, $DudeParam
                                    invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $GrantWithRightsOnSchema -Variable $ParamArray
                                    }
                                }   
                        
                  }
                            
          
         default { write-host ("Object type of " + $UserPermission.Object_type + " is unrecognized")}
     }
}

####################################################################
##The expansion of this script to handle custom roles would be here



##############################################################
##Run all the group membership queries!

foreach ($GroupPermission in $UserGroupList) 
{
        $LoopDBName = $GroupPermission.Database_Name
        $GroupParam = "TheGroup=" + $GroupPermission.GroupName
        $DudeParam = "TheDude=" + $GroupPermission.UserName
        $ParamArray = $GroupParam, $DudeParam
        invoke-sqlcmd -ServerInstance $DestServerName -Database $LoopDBName -Query $AddMemberToRole -Variable $ParamArray
}
    
