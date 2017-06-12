$app = Get-WmiObject -Class Win32_Product -ComputerName WG0501TRAIN10 -filter "Name = '7-zip'”
$app.Uninstall()


#.\psexec.exe \\WG0501RT -u rush\ktobola -p sept!1984  MsiExec.exe /X {ECEA7878-2100-4525-915d-B09174e36971} /qn

#msiexec /x{Package | ProductCode}