param(
$SRCServerName = $env:COMPUTERNAME,
$DBName = "RHA_ACCOUNTABLE_CARE_MART_QA",
$AuditDBName = "RHA_AUDIT"
)

$TheDate = Get-Date
$runDir = (Get-Location).Path
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

 cd $Rundir
######################################################
# $UserGroupQuery gets list of group memeberships
# $UserPermissionsQuery gets all explicit permissions
######################################################
$UserGroupQuery=@"
SELECT DP2.name AS DatabaseUserName, DP1.name AS DatabaseRoleName FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id where ((dp2.type='S' or dp2.type = 'U') and  (dp2.[name] not in ('dbo','sys','guest','INFORMATION_SCHEMA')))
ORDER BY DP2.name; 
"@

$UserPermissionsQuery=@"
SELECT DP.class_desc AS object_type, GR.type_desc AS grantor_user_type, GR.name AS grantor, GE.type_desc AS grantee_user_type, GE.name AS grantee,
DP.permission_name, state_desc,
    CASE
        WHEN S.name  IS NOT NULL    THEN S.name
        ELSE ISNULL(OBJECT_SCHEMA_NAME(DP.major_id), 'all_database')
    END AS [schema_name],
    CASE
        WHEN S.name  IS NOT NULL    THEN NULL
        ELSE OBJECT_NAME(DP.major_id)
    END AS [table_name]
    FROM sys.database_permissions DP
    INNER JOIN sys.database_principals GR ON GR.principal_id = DP.grantor_principal_id
    INNER JOIN sys.database_principals GE ON GE.principal_id = DP.grantee_principal_id
    LEFT JOIN sys.schemas AS S ON S.schema_id = DP.major_id
    WHERE NOT (ISNULL(OBJECT_SCHEMA_NAME(DP.major_id), 'all_database') = 'sys' 
        AND DP.class_desc = 'OBJECT_OR_COLUMN') AND GE.[name] NOT in ('dbo', 'sys', 'guest', 'INFORMATION_SCHEMA')
"@

##Populates Arrays using SQL Queries above
$UserGroupList = invoke-sqlcmd -ServerInstance $SrcServerName -Database $DBName -Query $UserGroupQuery
$UserPermissionsList = invoke-sqlcmd -ServerInstance $SrcServerName -Database $DBName -Query $UserPermissionsQuery

#############################################
#Create Schema and Tables in RHA_Audit DBS
#If they do not exist. 
############################################

$CreateAuditSchema=@"
IF NOT EXISTS (
SELECT  schema_name
FROM    information_schema.schemata
WHERE   schema_name = 'rha_dbPermissions' ) 
BEGIN
EXEC sp_executesql N'CREATE SCHEMA rha_dbPermissions'
END
"@

$CreateGroupAuditTable=@"
if not exists (select * from sysobjects where name='GroupMembership' and xtype='U')
create table rha_dbPermissions.GroupMembership (
        BatchNumber bigint not null,
        Database_Name varchar(64) not null,
        GroupName varchar(64) not null,
        UserName varchar(64) not null,
        RunDate datetime not null
    )
go
"@

$CreatePermissionsAuditTable=@"
if not exists (select * from sysobjects where name='UserPermissions' and xtype='U')
create table rha_dbPermissions.UserPermissions (
        BatchNumber bigint not null,
        Database_Name varchar(64) not null,
        Object_Type varchar(64) not null,
        Grantor_User_Type varchar(64) not null,
        Grantor varchar(64) not null,
        Grantee_User_Type varchar(64) not null,
        Grantee varchar(64) not null,
        permission_name varchar(64) not null,
        state_desc varchar(64) not null,
        schema_name varchar(64) not null,
        table_name varchar(64) null,
        RunDate datetime not null
    )
go
"@

#Creates the tables in the AuditDB
#$AuditDb name variable set at very beginning
invoke-sqlcmd -ServerInstance $SrcServerName -Database $AuditDBName -Query $CreateAuditSchema
invoke-sqlcmd -ServerInstance $SrcServerName -Database $AuditDBName -Query $CreateGroupAuditTable
invoke-sqlcmd -ServerInstance $SrcServerName -Database $AuditDBName -Query $CreatePermissionsAuditTable


###########################################################
##Insert the Data into the  Audit Tables
###########################################################

#get batchnumber
$batch_num_query = "select max(BatchNumber) from [rha_dbPermissions].[GroupMembership]"
$batch_num_List = invoke-sqlcmd -ServerInstance $SrcServerName -Database $AuditDBName -Query $batch_num_query
if ($batch_num_List.Column1 -like "") #Black freaking magic
    { $batch_num = 1}
else 
    { $batch_num = $batch_num_List.Column1 + 1 }

#declare the insert statements    
$Group_Audit_Insert_Query =@"
INSERT INTO [rha_dbPermissions].[GroupMembership] 
([BatchNumber], [Database_Name], [GroupName], [UserName], [Rundate]) values 
(`$(BatchNum), `$(DBName), `$(GroupName), `$(UserName), `$(RunDate))
"@   
    
$Permissions_Audit_Insert_Query =@"
INSERT INTO [rha_dbPermissions].[UserPermissions]
([BatchNumber], [Database_Name], [Object_Type], [Grantor_User_Type], [Grantor], [Grantee_User_Type], [Grantee], 
[permission_name], [state_desc], [schema_name], [table_name], [RunDate])
VALUES
(`$(BatchNum), `$(DBName), `$(Obj_Type), `$(Gor_U_Type), `$(Gor), `$(Gee_U_Type), `$(Gee), `$(Perm), `$(S_Desc), `$(Schema), `$(Table), `$(RunDate))
"@

$GetDate = "GetDate()"
##loop through the queried group data and insert it
foreach ($UserItem in $UserGroupList)
{
        $Group_Ins_Param1 = "BatchNum=" + $Batch_num
        $Group_Ins_Param2 = "DBName='" + $DBName + "'"
        $Group_Ins_Param3 = "GroupName='" + $UserItem.DataBaseRoleName + "'"
        $Group_Ins_Param4 = "UserName='" + $UserItem.DataBaseUserName + "'"
        $Group_Ins_Param5 = "RunDate=" + $GetDate
        $Group_Ins_Params = $Group_Ins_Param1, $Group_Ins_Param2, $Group_Ins_Param3, $Group_Ins_Param4, $Group_Ins_Param5
        Invoke-Sqlcmd -Query $Group_Audit_Insert_Query -Variable $Group_Ins_Params -ServerInstance $SrcServerName -Database $AuditDBName
}


##loop through the queried permissions data and insert it     
foreach ($UserPermission in $UserPermissionsList)
{
        $Perm_Ins_Param1 = "BatchNum=" + $Batch_num
        $Perm_Ins_Param2 = "DBName='" + $DBName + "'"
        $Perm_Ins_Param3 = "Obj_Type='" + $UserPermission.object_type + "'"
        $Perm_Ins_Param4 = "Gor_U_Type='" + $UserPermission.grantor_user_type + "'"
        $Perm_Ins_Param5 = "Gor='" + $UserPermission.grantor + "'"
        $Perm_Ins_Param6 = "Gee_U_Type='" + $UserPermission.grantee_user_type + "'"
        $Perm_Ins_Param7 = "Gee='" + $UserPermission.grantee + "'"
        $Perm_Ins_Param8 = "Perm='" + $UserPermission.permission_name + "'"
        $Perm_Ins_Param9 = "S_Desc='" + $UserPermission.state_desc + "'"
        $Perm_Ins_Param10 = "Schema='" + $UserPermission.schema_name + "'"
        $Perm_Ins_Param11 = "Table='" + $UserPermission.table_name + "'"
        $Perm_Ins_Param12 = "RunDate=" + $GetDate
        $Perm_Ins_Params = $Perm_Ins_Param1, $Perm_Ins_Param2, $Perm_Ins_Param3, $Perm_Ins_Param4, $Perm_Ins_Param5, $Perm_Ins_Param6, $Perm_Ins_Param7, $Perm_Ins_Param8, $Perm_Ins_Param9, $Perm_Ins_Param10, $Perm_Ins_Param11, $Perm_Ins_Param12
        Invoke-Sqlcmd -Query $Permissions_Audit_Insert_Query -Variable $Perm_Ins_Params -ServerInstance $SrcServerName -Database $AuditDBName
}


##Get UserList
##For each user in userlist
    ###if not exists, create user
    ###add user to group/role
