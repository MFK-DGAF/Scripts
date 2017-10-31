netsh firewall set portopening protocol = TCP port = 1434 name = SQLPort mode = ENABLE scope = SUBNET profile = CURRENT

pause

netsh advfirewall firewall add rule name="SQL" dir=in action=allow protocol=TCP localport=1433