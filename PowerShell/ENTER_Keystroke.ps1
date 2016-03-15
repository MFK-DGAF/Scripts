#This PowerShell command is to simulate the ENTER button keystroke
#http://stackoverflow.com/questions/17849522/how-to-perform-keystroke-inside-powershell


$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate('title of the application window')
Sleep 1
$wshell.SendKeys('~')