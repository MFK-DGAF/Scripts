--creates the mirroring for the principal server
CREATE ENDPOINT [RHA_MIRRORING_1430]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 1430, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM RC4)
	
--shows the list of the tcp endpoints	
select name, type_desc, port, ip_address from sys.tcp_endpoints;

--should show if the specified db is being mirrored
SELECT db.name, m.mirroring_role_desc
FROM sys.database_mirroring m 
JOIN sys.databases db
ON db.database_id = m.database_id
WHERE db.name = N'RHA';

--list the mirroring endpoint status
select name, role_desc, state_desc from sys.database_mirroring_endpoints

--set the other companions
ALTER DATABASE RHA
	SET PARTNER = 'TCP://maryann.rhadata.rushhealthassociates.com:1440'
GO

ALTER DATABASE RHA
	SET WITNESS = 'TCP://10.1.4.143:1450'
GO







--remove the mirroring endpoint
drop endpoint mirroring

