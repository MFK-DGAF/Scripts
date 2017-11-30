USE [RHA_ACCOUNTABLE_CARE_MART_VISIT]
GO
CREATE USER [itseitli] FOR LOGIN [itseitli]
GO
ALTER ROLE [db_owner] ADD MEMBER [itseitli]
GO
CREATE USER [mfavis1] FOR LOGIN [mfavis1]
GO
ALTER ROLE [db_owner] ADD MEMBER [mfavis1]
GO
CREATE USER [pbroeksm] FOR LOGIN [pbroeksm]
GO
ALTER ROLE [db_owner] ADD MEMBER [pbroeksm]
GO