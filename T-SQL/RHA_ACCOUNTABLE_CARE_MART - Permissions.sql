USE [RHA_ACCOUNTABLE_CARE_MART]
GO
DROP USER [RHADATA\edwteam]
GO
DROP USER [RHADATA\nchevula]
GO
DROP USER [rmanager]
GO
CREATE USER [RHADATA\edwteam] FOR LOGIN [RHADATA\edwteam]
GO
ALTER ROLE [db_owner] ADD MEMBER [RHADATA\edwteam]
GO
CREATE USER [RHADATA\nchevula] FOR LOGIN [RHADATA\nchevula]
GO
ALTER ROLE [db_owner] ADD MEMBER [RHADATA\nchevula]
GO
CREATE USER [rmanager] FOR LOGIN [rmanager]
GO
ALTER ROLE [db_datareader] ADD MEMBER [rmanager]
GO
GRANT EXECUTE TO [rmanager]
GO
CREATE USER [afrazie1] FOR LOGIN [afrazie1]
GO
ALTER ROLE [db_datareader] ADD MEMBER [afrazie1]
GO
CREATE USER [dthomps4] FOR LOGIN [dthomps4]
GO
ALTER ROLE [db_datareader] ADD MEMBER [dthomps4]
GO