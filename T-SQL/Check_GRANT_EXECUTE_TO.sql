DECLARE @username nvarchar(128) = 'rmanager';

SELECT COUNT(*) FROM sys.database_permissions 
    WHERE grantee_principal_id = (SELECT UID FROM sysusers WHERE name = @username) 
        AND class_desc = 'DATABASE'
        AND type='EX' 
        AND permission_name='EXECUTE' 
        AND state = 'G';

--Source: https://serverfault.com/questions/726269/check-whether-grant-execute-to-user-or-role-was-applied

--Result 0 means negative answer, 1 means positive.