DECLARE @msg VARCHAR(max)
DECLARE @count INT

SET @msg = ''
SET @count = 0

SELECT @msg = @msg + '"' + sj.name + '", ', @count = @count + 1
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobservers sjs ON sj.job_id = sjs.job_id
WHERE sjs.last_run_outcome = 0
AND (sj.name='MAINTENANCE_BackupDBs' OR sj.name='MAINTENANCE_FullBackup' OR sj.name='MAINTENANCE_DiffBackup')


IF @count = 0
                SET @msg = 'No failed jobs found'
ELSE
         SET @msg = 'Following job(s) failed: ' + SUBSTRING(@msg, 0, LEN(@msg)) 

SELECT @count as cnt, @msg as msg