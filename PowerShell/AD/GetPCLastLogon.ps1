# This is in Powershell.
# Thanks to  Ben Lye from the link: http://sysadmin-talk.org/2010/02/finding-stale-accounts-in-ad-with-windows-powershell/
# I was able to modify it and make it run in a Windows 7 computer over a Server 2008 environment.
# To run you need to be able to run PowerShell. Download the file to any location and give it a name ending with the extension .ps1 (example: GetPCLastLogon.ps1)
# In W7, logged on with admin rights to the network, open PowerShell by right-clicking and Run-As-Administrator from Start>Accessories>Windows PowerShell
# If this is the first time running PowerShell then enter this command to allow you to run cmdlets: Set-ExecutionPolicy RemoteSigned
# Now type in the following command to create a file in the desktop with the PC name and the last logon time (using the example above that I saved in my user desktop).
# Also you need to replace where it says "myuser" for your username. If you saved the file in a different location then replace the path for that location. Here is the command:
# c:\users\ktobola\desktop\GetPCLastLogon.ps1 > "c:\users\ktobola\desktop\PCLastLogon.csv"


# Calculate the UTC time, in FileTime (Integer) format and convert it to a string
$LLTSlimit = (Get-Date).ToFileTimeUTC().ToString()

# Create the LDAP filter for the AD query
# Searching for ***enabled*** computer accounts which have lastLogonTimestamp
$LDAPFilter = "(&(objectCategory=Computer)(lastLogonTimestamp<=$LLTSlimit) (!(userAccountControl:1.2.840.113556.1.4.803:=2)))"

# Create an ADSI Searcher to query AD
$Searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
$Searcher.filter = $LDAPFilter

# Execute the query
$Accounts = $Searcher.FindAll()

# Process the results
If ($Accounts.Count –gt 0)
{
	$Results = @() # Create an array to store all the results
	ForEach ($Account in $Accounts) # Loop through each account
	{ 
		$Result = "" | Select-Object Name,ADSPath,lastLogonTimestamp # Create an object to store this account in
		$Result.Name = [String]$Account.Properties.name # Add the name to the object as a string
		$Result.ADSPath = [String]$Account.Properties.adspath # Add the ADSPath to the object as a string
		$Result.lastLogonTimestamp = [DateTime]::FromFileTime([Int64]::Parse($Account.Properties.lastlogontimestamp)) # Add the lastLogonTimestamp to the object as a readable date
		$Results = $Results + $Result # Add this object to our array
	}
}

# Output the results
$Results | Format-Table -autosize