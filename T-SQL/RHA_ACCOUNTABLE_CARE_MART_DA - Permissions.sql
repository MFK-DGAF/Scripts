USE [RHA_ACCOUNTABLE_CARE_MART_DA]
GO
DROP USER [RHADATA\edwteam]
GO
DROP USER [RHADATA\nchevula]
GO
CREATE USER [itseitli] FOR LOGIN [itseitli]
GO
ALTER ROLE [db_owner] ADD MEMBER [itseitli]
GO
CREATE USER [pbroeksm] FOR LOGIN [pbroeksm]
GO
ALTER ROLE [db_owner] ADD MEMBER [pbroeksm]
GO