--create Witness Endpoint
CREATE ENDPOINT [RHA_MIRRORING_1450]
	STATE = STARTED
	AS TCP (LISTENER_PORT = 1450, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = WITNESS, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM RC4)
	
	
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

--drops the endpoint
drop endpoint RHA_Mirroring_1450