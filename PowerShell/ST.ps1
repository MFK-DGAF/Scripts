$x = read-host -prompt "Please enter the machine name:"
get-wmiobject -computername $x -class win32_bios
pause