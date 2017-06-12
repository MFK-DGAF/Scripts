#Specifiy Local User

  $UserName = "Administrator"

#Specify Computer

  $Computername = $env:COMPUTERNAME

#Connect to Local User on Local Computer

  $User = [adsi]"WinNT://$Computername/$UserName,user"

#Disable Specified User

  $User.AccountDisabled = $True

#Commit Changes

  $User.SetInfo()

