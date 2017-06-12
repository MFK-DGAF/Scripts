param (
[string]$userName, 
[string]$Dir, 
[string]$domain = "RUSH",
[switch]$recursive
)

import-module NTFSSecurity

if ($username.LastIndexOf("\") -eq -1)
{
    $username = write-output ($domain + "\" + $userName)
}

#$user = (Invoke-Expression $userName)



Get-ChildItem -Path $Dir -Recurse | Get-NTFSAccess -Account $username -ExcludeInherited |Remove-NTFSAccess