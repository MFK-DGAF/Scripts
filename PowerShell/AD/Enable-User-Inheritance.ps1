Import-Module ActiveDirectory

$users = Get-ADUser -ldapfilter “(objectclass=user)” -searchbase “ou=RHAWebAccounts,dc=rhadata,dc=rushhealthassociates,dc=com”
ForEach($user in $users)
{
    # Binding the users to DS
    $ou = [ADSI](“LDAP://” + $user)
    $sec = $ou.psbase.objectSecurity
 
    if ($sec.get_AreAccessRulesProtected())
    {
        $isProtected = $false ## allows inheritance
        $preserveInheritance = $true ## preserver inhreited rules
        $sec.SetAccessRuleProtection($isProtected, $preserveInheritance)
        $ou.psbase.commitchanges()
        Write-Host “$user is now inherting permissions”;
    }
    else
    {
        Write-Host “$User Inheritable Permission already set”
    }
}