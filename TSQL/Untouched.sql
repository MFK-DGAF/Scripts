CREATE PROCEDURE dbo.AddNewDBsToGroup
  @group SYSNAME = N'your_group_name', -- *** SPECIFY YOUR GROUP NAME HERE ***
  @path  SYSNAME = N'\\atel-web-be2\backups\',
  @debug BIT = 1
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE 
    @sql        NVARCHAR(MAX) = N'',
    @remote_sql NVARCHAR(MAX) = N'';

  DECLARE @t TABLE(db SYSNAME);

  INSERT @t SELECT name FROM sys.databases 
  WHERE replica_id IS NULL AND database_id > 4;

  DECLARE @r TABLE(s NVARCHAR(512));

  -- get the *healthy* replicas available for this group
  -- you'll need error handling to handle cases where any
  -- of the replicas is currently *not* healthy. This 
  -- script does not tell you this happened.

  INSERT @r SELECT r.replica_server_name
  FROM sys.availability_groups AS g
  INNER JOIN sys.dm_hadr_availability_group_states AS s
  ON g.group_id = s.group_id
  INNER JOIN sys.availability_replicas AS r
  ON g.group_id = r.group_id
  AND r.replica_server_name <> @@SERVERNAME
  WHERE g.name = @group
  AND s.primary_replica = @@SERVERNAME
  AND s.primary_recovery_health_desc = 'ONLINE'
  AND s.synchronization_health_desc = 'HEALTHY';

  -- add the database to the group on the primary:

  SELECT @sql += N'ALTER AVAILABILITY GROUP ' 
    + QUOTENAME(@group) + ' ADD DATABASE ' + QUOTENAME(db) + ';'
  FROM @t;

  IF @debug = 1
  BEGIN
    PRINT @sql;
  END
  ELSE
  BEGIN
    EXEC master..sp_executesql @sql;
  END

  -- back up the database locally:
  -- this assumes your database names don't have characters illegal for paths

  SET @sql = N'';

  SELECT @sql += N'BACKUP DATABASE ' + QUOTENAME(db) -- ** BACKUP HAPPENS HERE **
    + ' TO DISK = ''' + @path + db + '.BAK'' WITH COPY_ONLY, FORMAT, INIT, COMPRESSION;
    BACKUP LOG ' + QUOTENAME(db) +
    ' TO DISK = ''' + @path + db + '.TRN'' WITH INIT, COMPRESSION;'
  FROM @t;

  IF @debug = 1
  BEGIN
    PRINT @sql;
  END
  ELSE
  BEGIN
    EXEC master..sp_executesql @sql;
  END

  -- restore the database remotely:
  -- this assumes linked servers match replica names, security works, etc.
  -- it also assumes that each replica has the exact sime data/log paths
  -- (in other words, your restore doesn't need WITH MOVE)

  SET @sql = N'';

  SELECT @sql += N'RESTORE DATABASE ' + QUOTENAME(db) -- ** RESTORE HAPPENS HERE **
    + ' FROM DISK = ''' + @path + db + '.BAK'' WITH REPLACE, NORECOVERY;
    RESTORE LOG ''' + @path + db + '.TRN'' WITH NORECOVERY;
    ALTER DATABASE ' + QUOTENAME(db) + ' SET HADR AVAILABILITY GROUP = '
    + QUOTENAME(@group) + ';'
  FROM @t; 

  SET @remote_sql = N'';

  SELECT @remote_sql += N'EXEC ' + QUOTENAME(s) + '.master..sp_executesql @sql;'
    FROM @r;

  IF @debug = 1
  BEGIN
    PRINT @sql;
    PRINT @remote_sql;
  END
  ELSE
  BEGIN
    EXEC sp_executesql @remote_sql, N'@sql NVARCHAR(MAX)', N'SELECT @@SERVERNAME;';
  END
END
GO