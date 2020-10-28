##Get License Data
$Lic = cscript C:\Windows\System32\slmgr.vbs /dli
##Build Regex query
[regex]$reg = "Description:.*(?<LicenseCapture>KMSCLIENT|MAK|OEM).*"
##Pull data you are looking for
$LicType = $reg.Match($lic)

##Create a registry key with the value You found
switch ($LicType.Groups["LicenseCapture"].Value) {
    'KMSCLIENT' {
        if (-not(Test-Path "HKLM:\Software\Type")){
            New-Item -Path "HKLM:\Software" -Name "Type"
        }
            New-ItemProperty -Path "HKLM:\Software\Type" -Name "Type" -Value $LicType.Groups["LicenseCapture"].Value -PropertyType String
    }
    'MAK' {
        if (-not(Test-Path "HKLM:\Software\Type")){
            New-Item -Path "HKLM:\Software" -Name "Type"
        }
            New-ItemProperty -Path "HKLM:\Software\Type" -Name "Type" -Value $LicType.Groups["LicenseCapture"].Value -PropertyType String
    }
    'OEM' {
        if (-not(Test-Path "HKLM:\Software\Type")){
            New-Item -Path "HKLM:\Software" -Name "Type"
        }
            New-ItemProperty -Path "HKLM:\Software\Type" -Name "Type" -Value $LicType.Groups["LicenseCapture"].Value -PropertyType String
    }
    Default {
        if (-not(Test-Path "HKLM:\Software\Type")){
            New-Item -Path "HKLM:\Software" -Name "Type"
        }
            New-ItemProperty -Path "HKLM:\Software\Type" -Name "Type" -Value $LicType.Groups["LicenseCapture"].Value -PropertyType String
    }
}