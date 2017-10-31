USE [master]
GO

/****** Object:  DdlTrigger [Database Creation Alert]    Script Date: 10/31/2017 4:26:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [Database Creation Alert]
ON ALL SERVER
FOR CREATE_DATABASE
AS
declare @results varchar(max)
declare @subjectText varchar(max)
declare @databaseName VARCHAR(255)
SET @subjectText = 'DATABASE Created on ' + @@SERVERNAME + ' by ' + SUSER_SNAME() 
SET @results = 
  (SELECT EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)'))
SET @databaseName = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]', 'VARCHAR(255)'))

--Uncomment the below line if you want to not be alerted on certain DB names
--IF @databaseName NOT LIKE '%Snapshot%'
EXEC msdb.dbo.sp_send_dbmail
 @profile_name = 'SQLAlerts',
 @recipients = 'Alerts@Rush-Health.com',
 @body = @results,
 @subject = @subjectText,
 @exclude_query_output = 1 --Suppress 'Mail Queued' message


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [Database Creation Alert] ON ALL SERVER
GO

