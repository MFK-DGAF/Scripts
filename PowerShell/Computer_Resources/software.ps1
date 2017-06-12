$app = Get-WmiObject -Class Win32_Product -ComputerName OBT0900DL
$app.Uninstall()
