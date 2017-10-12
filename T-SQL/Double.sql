--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect MARIO-SPDB1

USE [master]

GO

ALTER AVAILABILITY GROUP [SharePoint]
ADD DATABASE [Social DB];

GO

USE [master]

GO

ALTER AVAILABILITY GROUP [SharePoint]
ADD DATABASE [Sync DB];

GO

:Connect MARIO-SPDB1

BACKUP DATABASE [Social DB] TO  DISK = N'\\mario\SharePoint-DB\Backups\Social DB.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect LUIGI-SPDB1

RESTORE DATABASE [Social DB] FROM  DISK = N'\\mario\SharePoint-DB\Backups\Social DB.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect MARIO-SPDB1

BACKUP LOG [Social DB] TO  DISK = N'\\mario\SharePoint-DB\Backups\Social DB_20151021170949.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect LUIGI-SPDB1

RESTORE LOG [Social DB] FROM  DISK = N'\\mario\SharePoint-DB\Backups\Social DB_20151021170949.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect LUIGI-SPDB1


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'SharePoint'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [Social DB] SET HADR AVAILABILITY GROUP = [SharePoint];

GO

:Connect MARIO-SPDB1

BACKUP DATABASE [Sync DB] TO  DISK = N'\\mario\SharePoint-DB\Backups\Sync DB.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect LUIGI-SPDB1

RESTORE DATABASE [Sync DB] FROM  DISK = N'\\mario\SharePoint-DB\Backups\Sync DB.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect MARIO-SPDB1

BACKUP LOG [Sync DB] TO  DISK = N'\\mario\SharePoint-DB\Backups\Sync DB_20151021170949.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect LUIGI-SPDB1

RESTORE LOG [Sync DB] FROM  DISK = N'\\mario\SharePoint-DB\Backups\Sync DB_20151021170949.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect LUIGI-SPDB1


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'SharePoint'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [Sync DB] SET HADR AVAILABILITY GROUP = [SharePoint];

GO


GO


