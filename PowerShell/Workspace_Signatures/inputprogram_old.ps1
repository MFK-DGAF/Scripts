$XMLText = new-object system.collections.arraylist

$FullName = Read-Host "Enter the User's Full Name"
#$LastName = Read-Host "Enter the User's Last Name"
$UserName = Read-Host "Enter Username"
$Title = Read-Host "Enter the User's title"
$Workstation = Read-Host "Enter Workstation Name"
$SourceDir = Read-Host "Enter the Source Directory"
$EmailAddress = Read-Host "Enter Email Address"
$PhoneNumber = Read-Host "Enter the Phone Number"
$FaxNumber = Read-Host "Enter the Fax Number (blank for default)"
$OBT = Read-Host "Does the User work at OBT?"
$OfficeHours = Read-Host "Does the User have office hours?"

$RGreenHex = "#006f3c"
$LGreenHex = "#64a70b"
$DBlueHex = "#00648c"
$LBlueHex = "#00adca"
$OrangeHex = "#f17922"

if ($Workstation -eq "")
    {
        $DesinationDir = 'C:\Users\tspooner\Documents\Workspace\'
    }
else
    {
        $DestinationDir = write-output ("\\" + $Workstation + "\c$\Users\" + $UserName + "\AppData\Roaming\Microsoft\Signatures\")
    }
    
if ($sourceDir -eq "")
    {
        $SourceDir = 'C:\Users\tspooner\Documents\Workspace\'
    }

##This logic enters the default fax number fOr any user who has not specified a fax number
if ($FaxNumber -eq "")
	{
	if ($OBT -eq "" -Or $OBT -eq "no" -Or $OBT -eq "n")
		{
		$FaxNumber = "312.942.5831"
		}
	#insert the logic fOr setting the blank Fax Number to the OBT Fax nubmer
	}

	
if ($UserName -ne "")
	{
	if ($OBT -eq "" -Or $OBT -eq "no" -Or $OBT -eq "n")
		{
		if ($OfficeHours -eq "n" -Or $OfficeHours -eq "No")
			{	
            
            
            $TemplateFile = write-output ($SourceDir + "Template-Color.htm")
			$TemplateHTML = get-content $TemplateFile
			#$WorkingDir = 'C:\Users\tspooner\Documents\Workspace\'
			$FilesDir = write-output ($SourceDir + "Template-color_Files\")
			$TemplateHTML = $TemplateHTML -replace "!Name",$FullName
			$TemplateHTML = $TemplateHTML -replace "!Title",$Title
			$TemplateHTML = $TemplateHTML -replace "!Email",$EmailAddress
			$TemplateHTML = $TemplateHTML -replace "!Phone",$PhoneNumber
			$TemplateHTML = $TemplateHTML -replace "!Fax",$FaxNumber
			$TemplateHTML = $TemplateHTML -replace "!LastName",$UserName
				
			$TemplateHTMLRGreen = $TemplateHTML -replace "!ColorName","RGreen"
			$TemplateHTMLRGreen = $TemplateHTMLRGreen -replace "!ColorHex",$RGreenHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-RGreen.htm')
			$TemplateHTMLRGreen | Set-Content $OutPutFile
			$RGreenDir = write-output ($DestinationDir+$UserName+"-RGreen_Files\")
			Copy-Item $FilesDir $RGreenDir -recurse
			$FileListFile = write-output ($RGreenDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color","RGreen"
			$FileListFileContent | Set-Content -Force $FileListFile
			
			$TemplateHTMLLGreen = $TemplateHTML -replace "!ColorName","LGreen"
			$TemplateHTMLLGreen = $TemplateHTMLRGreen -replace "!ColorHex",$LGreenHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-LGreen.htm')
			$TemplateHTMLRGreen | Set-Content $OutPutFile
			$LGreenDir = write-output ($DestinationDir+$UserName+"-LGreen_Files\")
			Copy-Item $FilesDir $LGreenDir -recurse
			$FileListFile = write-output ($LGreenDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color","LGreen"
			$FileListFileContent | Set-Content -Force $FileListFile
			
			$TemplateHTMLDBlue = $TemplateHTML -replace "!ColorName","DBlue"
			$TemplateHTMLDBlue = $TemplateHTMLDBlue -replace "!ColorHex",$DBlueHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-DBlue.htm')
			$TemplateHTMLDBlue | Set-Content $OutPutFile
			$DBlueDir = write-output ($DestinationDir+$UserName+"-DBlue_Files\")
			Copy-Item $FilesDir $DBlueDir -recurse
			$FileListFile = write-output ($DBlueDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color","DBlue"
			$FileListFileContent | Set-Content -Force $FileListFile
			
			$TemplateHTMLLBlue = $TemplateHTML -replace "!ColorName","LBlue"
			$TemplateHTMLLBlue = $TemplateHTMLLBlue -replace "!ColorHex",$LBlueHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-LBlue.htm')
			$TemplateHTMLLBlue | Set-Content $OutPutFile
			$LBlueDir = write-output ($DestinationDir+$UserName+"-LBlue_Files\")
			Copy-Item $FilesDir $LBlueDir -recurse
			$FileListFile = write-output ($DBlueDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color","DBlue"
			$FileListFileContent | Set-Content -Force $FileListFile
			
			$TemplateHTMLOrange = $TemplateHTML -replace "!ColorName","Orange"
			$TemplateHTMLOrange = $TemplateHTMLOrange -replace "!ColorHex",$OrangeHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-Orange.htm')
			$TemplateHTMLOrange | Set-Content $OutPutFile
			$OrangeDir = write-output ($DestinationDir + $UserName + "-Orange_Files\")
			Copy-Item $FilesDir $OrangeDir -recurse
			$FileListFile = write-output ($OrangeDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color","Orange"
			$FileListFileContent | Set-Content -Force $FileListFile
			
			}
		}
	}

	