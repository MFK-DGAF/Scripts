#Connect to ADSI

$Computername = $env:COMPUTERNAME

  $ADSIComp = [adsi]"WinNT://$Computername" 

$Username = 'install'

  $NewUser = $ADSIComp.Create('User',$Username) 

#Set password on account 

  $NewUser.SetPassword("cb@sf03")

$NewUser.SetInfo()

#Set Description

$NewUser.Description  ='Local Admin'

#Set Password to never expire

$flag=$NewUser.UserFlags.value -bor 0x10000

  $NewUser.put("userflags",$flag)

#Commit Changes

$NewUser.SetInfo()

#Add User To Administrators Group

[ADSI]$group="WinNT://$Computername/Administrators,Group"

  $NewUser.path

$group.Add($NewUser.path)
