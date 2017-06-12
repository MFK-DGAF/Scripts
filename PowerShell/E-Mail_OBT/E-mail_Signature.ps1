$XMLText = new-object system.collections.arraylist

$FullName = Read-Host "Enter the Employee's Full Name"
$UserName = Read-Host "Enter Username"
$Title = Read-Host "Enter the User's title"
$Workstation = Read-Host "Enter Workstation Name"
$EmailAddress = Read-Host "Enter Email Address"
$PhoneNumber = Read-Host "Enter the Phone Number"
$FaxNumber = "630.954.3701"

##$RGreenHex = "#006f3c"
##$LGreenHex = "#64a70b"
##$DBlueHex = "#00648c"
##$LBlueHex = "#00adca"
##$OrangeHex = "#f17922"
    
$SourceDir = 'C:\Powershell\E-Mail_OBT\'
$DestinationDir = write-output ("\\" + $Workstation + "\c$\Users\" + $UserName + "\AppData\Roaming\Microsoft\Signatures\")
$TemplateFile = write-output ($SourceDir + "TemplateOBT-Color.htm")
$FilesDir = write-output ($SourceDir + "TemplateOBT-color_Files\")
	
if ($UserName -ne "")
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

pause	