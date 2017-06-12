pushd

Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\

New-ItemProperty -Name Manufacturer -PropertyType string -path OEMInformation -Value “Dell”

New-ItemProperty -Name Model -PropertyType string -path OEMInformation -Value “Optiplex 9020”

popd