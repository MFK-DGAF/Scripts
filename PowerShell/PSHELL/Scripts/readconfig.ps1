cls
$config_file = 'C:\PSHELL\FILECONFIG\testconfig.txt'
$config_recs = get-content $config_file
$config_recs[1]
$val = count