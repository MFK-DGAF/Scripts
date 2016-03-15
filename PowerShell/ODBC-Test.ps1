Add-OdbcDsn -Name "CPROCS_READONLY" -DriverName "SQL Server" -DsnType "System" -SetPropertyValue @("Server=144.74.81.247", "Trusted_Connection=Yes", "Database=CPROCS")
pause