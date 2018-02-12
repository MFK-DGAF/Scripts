USE [RHA_ACCOUNTABLE_CARE_MART_QA]
GO
DROP USER [RHADATA\edwteam]
GO
DROP USER [RHADATA\nchevula]
GO
DROP USER [rmanager]
GO
CREATE USER [itseitli] FOR LOGIN [itseitli]
GO
ALTER ROLE [db_owner] ADD MEMBER [itseitli]
GO
CREATE USER [mchester] FOR LOGIN [mchester]
GO
ALTER ROLE [db_owner] ADD MEMBER [mchester]
GO
CREATE USER [mfavis1] FOR LOGIN [mfavis1]
GO
ALTER ROLE [db_owner] ADD MEMBER [mfavis1]
GO
CREATE USER [rmanager] FOR LOGIN [rmanager]
GO
ALTER ROLE [db_datareader] ADD MEMBER [rmanager]
GO
GRANT EXECUTE TO [rmanager]
GO
CREATE USER [tpatel8] FOR LOGIN [tpatel8]
GO
ALTER ROLE [db_owner] ADD MEMBER [tpatel8]
GO
CREATE USER [afrazie1] FOR LOGIN [afrazie1]
GO
ALTER ROLE [db_datareader] ADD MEMBER [afrazie1]
GO
CREATE USER [dthomps4] FOR LOGIN [dthomps4]
GO
ALTER ROLE [db_datareader] ADD MEMBER [dthomps4]
GO