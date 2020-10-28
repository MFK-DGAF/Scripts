Param(
  [string] $OLD_GROUP_NAME,
  [string] $NEW_GROUP_NAME
)

$OLD_GROUP=Get-ADGroup -Filter { name -like $OLD_GROUP_NAME }

If ($OLD_GROUP -eq $null)
{
    "Cannot clone non-existent group ($OLD_GROUP_NAME)"
}
Else
{
    $OLD_GROUP_SCOPE=$OLD_GROUP.GroupScope
    $OLD_GROUP_DN=$OLD_GROUP.DistinguishedName
    $TEMP=$OLD_GROUP_DN.IndexOf(",")
    $OLD_GROUP_PATH=$OLD_GROUP_DN.SubString($TEMP+1,$OLD_GROUP_DN.Length-$TEMP-1)

    New-ADGroup -Name $NEW_GROUP_NAME -GroupScope $OLD_GROUP_SCOPE -path "$OLD_GROUP_PATH"
    Get-ADGroupMember -Identity $OLD_GROUP_NAME | Add-ADPrincipalGroupMembership -MemberOf $NEW_GROUP_NAME

    $NEW_GROUP=Get-ADGroup -Filter { name -like $NEW_GROUP_NAME }
    If ($NEW_GROUP -eq $null)
    {
        "Error creating group ($NEW_GROUP_NAME)"
    }
    Else
    {
        "Created new Group $NEW_GROUP_NAME (path $OLD_GROUP_PATH)"
    }
}