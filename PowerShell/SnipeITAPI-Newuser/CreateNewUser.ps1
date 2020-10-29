##################################################
###############~~~~~~~~~~~~~~~~~~~~###############
##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##########
#####     SnipeIT User API                   #####
#####     Made by Kevin Tobola                #####
#####     10/2020                            #####
#####                                        #####
#####     Version 1.0                        #####
##########~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##########
###############~~~~~~~~~~~~~~~~~~~~###############
##################################################

$ErrorActionPreference = "SilentlyContinue"
Import-Module ActiveDirectory
$PSScriptRoot
Add-Type -AssemblyName PresentationFramework

$RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
$RHAPI_logfile = "C:\temp\newuserapilog.txt"
if(!(Test-Path "C:\temp")) { New-Item -ItemType Directory -Path "C:\" -Name "Temp" }
$RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
$RHAPI_logtext = "$RHAPI_logtime - INFO - New User API triggered `n"

function newUserAPI {

    param (
        [string]$Username,
        [string]$Department
    )
        
<# Pull user information from argument (-Username) #>
    <# Query AD #>
    
    $script:RHAPI_APIGUIResults.Text = "Searching AD using $Username"
    $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
    $RHAPI_logtext += "$RHAPI_logtime - INFO - Searching AD using $Username`n"

    $RHAPI_theone = Get-Aduser -Filter {samAccountName -eq $Username} -SearchBase "OU GOES HERE" -Properties UserPrincipalName,employeeID,title,manager,physicalDeliveryOfficeName,l,department
    
    Write-Host $RHAPI_theone

    if(!($RHAPI_theone)){
        $script:RHAPI_APIGUIResults.Text = "Could not find user in AD. Check the name or username. Make sure you have the correct name and there are no spelling errors. Exiting API - No new user was created. Check Logs for more information."
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - ERROR - Could not find user in AD. Check the name or username. Make sure you have the correct name and there are no spelling errors. `n"
        $RHAPI_logtext += "$RHAPI_logtime - WARN - Exiting API - No new user was created."
        return $null
    }

    $script:RHAPI_APIGUIResults.Text = "Query for $Username was successful in AD"
    $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
    $RHAPI_logtext += "$RHAPI_logtime - INFO - Query for $Username was successful in AD"


    <# SnipeIT API #>
    <# SnipeIT User Properties
    - Company: Rush Health / Rush System for Health
    - First Name = Name.Split(" ")[0]
    - Last Name = Name.Split(" ")[Name.Split(" ").Count-1]
    - Username = sAMAccountName
    - Password
    - Confirm Password
    - Email = userPrincipalName
    - Language: English (Static)
    - Employee Number = employeeID
    - Title = title
    - Manager = manager > Do a search via API for manager's ID
    - Department = Second Arg AD: department
    - Location: Chicago / Oakbrook / Doctor.com AD: l
    - Active: No (Static)
    - Groups: Rush Health > All (Static) / Finance / Support Services
    #>

    <# Get User Attributes #>
    $RHAPI_ADnames = $RHAPI_theone.Name.Split(" ")
    $RHAPI_ADfirstname = $RHAPI_ADnames[0]
    $RHAPI_ADlastname = $RHAPI_ADnames[$RHAPI_ADnames.Count-1]
    $RHAPI_ADUsername = $RHAPI_theone.SamAccountName
    $RHAPI_ADemail = $RHAPI_theone.UserPrincipalName
    $RHAPI_ADtitle = $RHAPI_theone.title
    $RHAPI_ADeid = $RHAPI_theone.employeeID
    if($RHAPI_theone.l -ne $null){ $ADlocation = $RHAPI_theone.l } else { $ADlocation = "Chicago" }
    $RHAPI_ADmanager = $RHAPI_theone.manager

    <# Pull Deptartment ID #>
    $RHAPI_dept_id = ($RHAPI_alldepts | ?{$_.Name -eq $Department}).id

    <# Pull Manager Information #>
    if($RHAPI_ADmanager -ne $null -AND $RHAPI_ADmanager -ne ""){
        $RHAPI_ADMemail = (Get-Aduser -Filter {distinguishedName -eq $RHAPI_ADmanager} -SearchBase "OU GOES HERE").UserPrincipalName
    }

    <# List Static Variables and values #>
    $RHAPI_company = @{
        "Rush Health" = 1
        "Rush System for Health" = 3
    }
    $RHAPI_location = @{
        "Chicago" = 1
        "Oakbrook" = 2
        "Doctor.com" = 3
    }
    $RHAPI_isactive = "false"
    $RHAPI_temppw = "P@ssword!1"
    $RHAPI_groups = @{
        "Rush Health" = 3
        "Support Services" = 2
        "Finance" = 1
    }

    <# Pull Manager ID from Manager Email #>
    if($RHAPI_ADMemail -ne $null){
        $RHAPI_manapi = "https://asset.rush-health.com/api/v1/users?email=$RHAPI_ADMemail"
        $RHAPI_manresponse = Invoke-RestMethod $RHAPI_manapi -Method 'GET' -Headers $script:RHAPI_Headers
        $RHAPI_manid = $RHAPI_manresponse.rows.id

        $script:RHAPI_APIGUIResults.Text = "Query for Manager successful in SnipeIT"
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - INFO - Query for Manager successful in SnipeIT. Manager ID: $RHAPI_manid `n"

    } else {
        $RHAPI_manid = 150 ## Defaults to Anthony if no manager is found/set in AD.
        $script:RHAPI_APIGUIResults.Text = "$Username has not manager set in AD. Continuing with API..."
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - WARN - No manager set in AD. Defaulted to Executive Director `n"
    }

    <# Create new user in SnipeIT with following attributes #>
    $RHAPI_API = "https://asset.rush-health.com/api/v1/users?"
    $RHAPI_API += "username=$RHAPI_ADUsername"
    $RHAPI_API += "&first_name=$RHAPI_ADfirstname"
    $RHAPI_API += "&last_name=$RHAPI_ADlastname"
    $RHAPI_API += "&password=$RHAPI_temppw"
    $RHAPI_API += "&password_confirmation=$RHAPI_temppw"
    $RHAPI_API += "&email=$email"
    $RHAPI_API += "&activated=$RHAPI_isactive"
    $RHAPI_API += "&jobtitle=$RHAPI_ADtitle"
    $RHAPI_API += "&manager_id=$RHAPI_manid"
    $RHAPI_API += "&employee_num=$RHAPI_ADeid"
    $RHAPI_API += "&company_id="+$RHAPI_company["Rush Health"]
    $RHAPI_API += "&location_id="+$RHAPI_location[$ADlocation]
    $RHAPI_API += "&group_id="+$RHAPI_groups["Rush Health"]
    $RHAPI_API += "&department_id=$RHAPI_dept_id"

    Write-Host $RHAPI_API
    $script:RHAPI_APIGUIResults.Text = "Initiating API POST to SnipeIT for new user."
    $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
    $RHAPI_logtext += "$RHAPI_logtime - INFO - Manager ID for SnipeIT: $RHAPI_manid `n"

    $RHAPI_response = Invoke-RestMethod $RHAPI_API -Method 'POST' -Headers $script:RHAPI_Headers

    if($RHAPI_response.Status -eq "success"){
        $script:RHAPI_APIGUIResults.Text = "$Username added to SnipeIT successfully"
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - INFO - $Username added to SnipeIT successfully`n"
        return $RHAPI_response
    } else {
        $script:RHAPI_APIGUIResults.Text = "Error when calling API to create user... Exiting API - No new user was created. Check Logs for more information."
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - ERROR - Error when calling API to create user... Exiting API - No new user was created.`n"
        foreach ($em in $RHAPI_response.messages){
            $RHAPI_logtext += "$RHAPI_logtime - ERROR - $em `n"
        }
        return $null
    }

}

<# Set API Connection settings - DO NOT CHANGE #>
$RHAPI_apikey = 'API KEY GOES HERE'
$RHAPI_Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$RHAPI_Headers.Add("Accept", "application/json")
$RHAPI_Headers.Add("Content-Type", "application/json")
$RHAPI_Headers.Add("Authorization", "Bearer $RHAPI_apikey")
$RHAPI_Headers.Add("Bearer", "$RHAPI_apikey")


$RHAPI_alldepts = (Invoke-RestMethod 'https://asset.rush-health.com/api/v1/departments' -Method 'GET' -Headers $RHAPI_Headers).rows | Sort-Object Name

<# Start GUI #>
$RHAPI_xmlfilepath = "$PSScriptRoot\MainWindow.xaml"

if(!(Test-Path -Path $RHAPI_xmlfilepath)) { 
    Write-Host "NO XML template found. Cannot create GUI"
    exit 1
}
    
$RHAPI_xmldropbox = ""
foreach($ad in $RHAPI_alldepts){
    $RHAPI_xmldropbox += '<ListBoxItem Content="'+ $ad.Name +'"/>
        '
}

$RHAPI_guixml = Get-Content $RHAPI_xmlfilepath -Raw
$RHAPI_guixml = $RHAPI_guixml -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace '>!RUSHHEALTH!<', $RHAPI_xmldropbox
Write-Output $RHAPI_guixml
[XML]$RHAPI_XAML = $RHAPI_guixml

#Read XAML
$RHAPI_reader = (New-Object System.Xml.XmlNodeReader $RHAPI_XAML)
try {
    $RHAPI_window = [Windows.Markup.XamlReader]::Load( $RHAPI_reader )
} catch {
    Write-Warning $_.Exception
    throw
}

$RHAPI_XAML.SelectNodes("//*[@Name]") | ForEach-Object {
    ##$_.Name
    Set-Variable -Name "RHAPI_$($_.Name)" -Value $RHAPI_window.FindName($_.Name) -ErrorAction Stop
}


$RHAPI_APISub.Add_Click( {
    if($RHAPI_APIUN.Text -eq "" -or $RHAPI_APIUN.Text -eq $null -or $RHAPI_APIUN.Text.Length -lt 3){
        $RHAPI_APIUN.Text = "Enter a valid username."
    } else {
        $RHAPI_formUN = [string]$RHAPI_APIUN.Text
        $RHAPI_formDept = [string]$RHAPI_APIDept.Text

        $RHAPI_APIGUIResults.Text ="Valid AD Username entered. Initiating APIs... Please wait."
        $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
        $RHAPI_logtext += "$RHAPI_logtime - INFO - Valid AD Username entered. Initiating APIs... Username: $RHAPI_formUN | Department: $RHAPI_formDept`n "

        $RHAPI_results = newUserAPI -Username $RHAPI_formUN -Department $RHAPI_formDept
    }
} )

$RHAPI_APIExit.Add_Click( {
    $RHAPI_APIGUIResults.Text ="Closing API Script. Goodbye."
    $RHAPI_logtime = Get-Date -Format "hh:mm:ss tt on MM/dd/yyyy"
    $RHAPI_logtext += "$RHAPI_logtime - INFO - API Closed"

    Remove-Variable RHAPI_*

    $RHAPI_window.Close()
    exit 0
} )

$Null = $RHAPI_window.ShowDialog()