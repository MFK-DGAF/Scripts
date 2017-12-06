USE [RHA_ACCOUNTABLE_CARE_MART_BI]
GO
DROP USER [jengland]
GO
DROP USER [mfavis1]
GO
DROP USER [nchevula]
GO
DROP USER [RHADATA\BITeam]
GO
DROP USER [RHADATA\bwatkin1]
GO
DROP USER [RHADATA\nchevula]
GO
CREATE USER [RHADATA\nchevula] FOR LOGIN [RHADATA\nchevula]
GO
ALTER ROLE [db_owner] ADD MEMBER [RHADATA\nchevula]
GO
DROP USER [RHADATA\yshi]
GO
CREATE USER [RHADATA\yshi] FOR LOGIN [RHADATA\yshi]
GO
ALTER ROLE [db_owner] ADD MEMBER [RHADATA\yshi]
GO
DROP USER [tpatel8]
GO
CREATE USER [rmanager] FOR LOGIN [rmanager]
GO
ALTER ROLE [db_datareader] ADD MEMBER [rmanager]
GO
GRANT EXECUTE TO [rmanager]
GO
CREATE USER [tmurphy4] FOR LOGIN [tmurphy4]
GO
ALTER ROLE [db_datareader] ADD MEMBER [tmurphy4]
GO