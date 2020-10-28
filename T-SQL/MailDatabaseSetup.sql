--================================================================
-- Replace SERVERNAME with actual server name.
-- Replace password with actual password
--================================================================
USE master;
GO
 
sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO 

EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'SERVERNAME',
@description = 'Basic Support account using office365',
@email_address = 'noreply@rush-health.com',
@replyto_address = 'noreply@rush-health.com',
@display_name = 'noreply@rush-health.com',
@mailserver_name = 'smtp.office365.com',
@port=587,
@enable_ssl=1,
@username='noreply@rush-health.com',
@password='password'

EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'SERVERNAME',
@description = 'DB Mail Service for SQL Server' 

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'SERVERNAME',
@account_name = 'SERVERNAME',
@sequence_number =1 ;

EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
@profile_name = 'SERVERNAME',
@principal_id = 0,
@is_default = 1

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'SERVERNAME',
@recipients = 'noreply@rush-health.com',
@body = 'SQL Database Mail Test',
@subject = 'Databas Mail from SERVERNAME'