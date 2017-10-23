USE RHA_ACCOUNTABLE_CARE_MART_DA 
GO 
SELECT name, sid FROM sys.sysusers 
WHERE name = 'mfavis1' 
GO 
USE MASTER 
GO 
SELECT name, sid FROM sys.sql_logins 
WHERE name = 'mfavis1' 
GO