#########################################################################################
#   Rush Health Server Setup Script
#########################################################################################

#******************************************************************************
# File:     RH_Server_Setup.ps1
# Date:     003/31/2016
# Version:  1.0.0
#
# Purpose:  To automate the basic setup of a server.
#
# Requirements: Administraor access
#
# Revisions:
# ----------
# 1.0.0   03/31/2016   Created script.
#
#******************************************************************************

#*******************************************************************
# Set Execution Policy
#*******************************************************************

Set-ExecutionPolicy Unrestricted

#*******************************************************************
# Enables RDP and Adds Exception to Firewall
#*******************************************************************

(gwmi Win32_TerminalServiceSetting –Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1)

(gwmi Win32_TSGeneralSetting -Namespace root\cimv2\TerminalServices).SetUserAuthenticationRequired(0)

#*******************************************************************
# Sets TimeZone to Central Standard Time
#*******************************************************************

$TimeZone = "Central Standard Time"

$process = New-Object System.Diagnostics.Process 
  $process.StartInfo.WindowStyle = "Hidden" 
  $process.StartInfo.FileName = "tzutil.exe" 
  $process.StartInfo.Arguments = "/s `"$TimeZone`"" 
  $process.Start() | Out-Null 

#*******************************************************************
# Sets Date & Time
#*******************************************************************

$Date = Read-Host "Please Enter The Date Using Format XX/XX/XXXX"
$Time = Read-Host "Please Enter The Time Using Format XX:XX AM/PM"
Set-Date -date "$Date $Time"

#*******************************************************************
# Activates Balanced Power Settings Profile
# Sets Hibernation to Never
# Sets Hard Disks to Turn Off After Never
# Sets to Turn Display Off After Never
# Sets Allow Hybird Sleep to Never
# Sets Sleep After to Never
# Commits Changes to Balance Power Settings Profile
#*******************************************************************

(gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter "ElementName ='Balanced'").Activate()

$aa = (gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter { ElementName ='Balanced'}).instanceid.split("\")[1]

$ba = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Hibernate after' }).instanceid.split("\")[1]
$bb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ba'")
$bb.settingindexvalue = 0
$bb.Put()

$ca = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Turn off hard disk after' }).instanceid.split("\")[1]
$cb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ca'")
$cb.settingindexvalue = 0
$cb.Put()

$da = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Turn off display after' }).instanceid.split("\")[1]
$db = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$da'")
$db.settingindexvalue = 1500
$db.Put()

$ea = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Allow hybrid sleep' }).instanceid.split("\")[1]
$eb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ea'")
$eb.settingindexvalue = 0
$eb.Put()

$fa = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Sleep after' }).instanceid.split("\")[1]
$fb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$fa'")
$fb.settingindexvalue = 0
$fb.Put()

#*******************************************************************
# Sets The OEM Information
#*******************************************************************

pushd

Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\

$Manufacturer = Read-Host "Please Enter The Manuafacturer"

$Model = Read-Host "Please Enter The Model"

New-ItemProperty -Name Manufacturer -PropertyType string -path OEMInformation -Value “$Manufacturer”

New-ItemProperty -Name Model -PropertyType string -path OEMInformation -Value “$Model”

popd

#*******************************************************************
# Sets Computer Description
#*******************************************************************

Push-Location

Set-Location HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters

$value = Read-Host "Please Set The Description For This System"

Set-ItemProperty . srvcomment “$value”

Pop-Location

#*******************************************************************
# Create User 'install'
#*******************************************************************

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

#*******************************************************************
# Disable Administrator Account
#*******************************************************************

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


#*******************************************************************
# Rename Computer
#*******************************************************************

$Name = Read-Host "Enter Name For This Computer"
(gwmi Win32_ComputerSystem).rename($Name)

#*******************************************************************
# Connect Server to Domain
#*******************************************************************

$domain = Read-Host -Prompt "Enter FQDN"
$user = Read-Host -Prompt "Enter Username" 
$password = Read-Host -Prompt "Enter password for $user" -AsSecureString 
$username = "$domain\$user" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password) 
Add-Computer -DomainName $domain -Credential $credential

#*******************************************************************
# Tell User To Restart
#*******************************************************************

Read-Host -Prompt "Please Restart the System..."





















