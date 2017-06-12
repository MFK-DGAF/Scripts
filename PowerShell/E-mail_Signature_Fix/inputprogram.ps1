$XMLText = new-object system.collections.arraylist

$FullName = Read-Host "Enter the User's Full Name"
#$LastName = Read-Host "Enter the User's Last Name"
$UserName = Read-Host "Enter Username"
$Workstation = Read-Host "Enter Workstation Name"
$Title = Read-Host "Enter the User's title"
$SourceDir = Read-Host "Enter the Source Directory"
$EmailAddress = Read-Host "Enter Email Address"
$PhoneNumber = Read-Host "Enter the Phone Number"
$FaxNumber = Read-Host "Enter the Fax Number (blank for default)"
$OBT = Read-Host "Does the User work at OBT?"
$OfficeHours = Read-Host "Does the User have office hours?"

##$RGreenHex = "#006f3c"
##$LGreenHex = "#64a70b"
##$DBlueHex = "#00648c"
##$LBlueHex = "#00adca"
##$OrangeHex = "#f17922"

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
    else
        {
        $FaxNumber = "630.954.3701"
        }
	#insert the logic fOr setting the blank Fax Number to the OBT Fax nubmer
	}
    
if ($OBT -eq "" -Or $OBT -eq "no" -Or $OBT -eq "n")
    {
    if ($OfficeHours -eq "n" -Or $OfficeHours -eq "No" -Or $OfficeHours -eq "")
		{   
            $TemplateFile = write-output ($SourceDir + "Template-Color.htm")
            $FilesDir = write-output ($SourceDir + "Template-color_Files\")
        }
    }
    
if ($OBT -eq "Y" -Or $OBT -eq "y" -Or $OBT -eq "true" -Or $OBT -eq "yes")
    {   
        $TemplateFile = write-output ($SourceDir + "TemplateOBT-Color.htm")
        $FilesDir = write-output ($SourceDir + "TemplateOBT-color_Files\")
    }

	
if ($UserName -ne "")
	{
	if ($OfficeHours -eq "n" -Or $OfficeHours -eq "No" -Or $OfficeHours -eq "")
		{
        $TemplateHTML = get-content $TemplateFile                 
		$TemplateHTML = $TemplateHTML -replace "!Name",$FullName
		$TemplateHTML = $TemplateHTML -replace "!Title",$Title
		$TemplateHTML = $TemplateHTML -replace "!Email",$EmailAddress
		$TemplateHTML = $TemplateHTML -replace "!Phone",$PhoneNumber
		$TemplateHTML = $TemplateHTML -replace "!Fax",$FaxNumber
		$TemplateHTML = $TemplateHTML -replace "!LastName",$UserName
		$Colors = @("LBlue","DBlue","LGreen","RGreen","Orange")
            
        foreach ($color in $Colors)
            { 
            if ($color -eq "LBlue"){
                $ColorHex = "#00adca"}
            if ($color -eq "DBlue"){
                $ColorHex = "#00648c"}
            if ($color -eq "LGreen"){
                $ColorHex = "#64a70b"}
            if ($color -eq "RGreen"){
                $ColorHex = "#006f3c"}   
            if ($color -eq "Orange"){
                $ColorHex = "#f17922"}
                       
            $TemplateHTMLColor = $TemplateHTML -replace "!ColorName", $Color
			$TemplateHTMLColor = $TemplateHTMLColor -replace "!ColorHex", $ColorHex
			$OutPutFile = write-output ($DestinationDir + $UserName + '-' + $color + '.htm')
			$TemplateHTMLColor | Set-Content $OutPutFile
			$ColorDir = write-output ($DestinationDir + $UserName + "-" + $color + "_Files\")
			Copy-Item $FilesDir $ColorDir -recurse
			$FileListFile = write-output ($ColorDir + "filelist.xml")
			$FileListFileContent = get-content $FileListFile
			$FileListFileContent = $FileListFileContent -replace "!LastName",$UserName
			$FileListFileContent = $FileListFileContent -replace "!Color", $Color
			$FileListFileContent | Set-Content -Force $FileListFile
			}
		}
	}

	