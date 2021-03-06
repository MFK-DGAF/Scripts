import-module sqlps

######################################################
#Sets Variables
######################################################
$UserName = "UserName"
$emailAddress = "Name@email.com"

$listlocation = "E:\Automation\Maintenance_PurgeSQLAccount\Serverlist.txt"
###############################################################
# This function removes a username from a database on a server
# It returns whatever error occurs on the command
###############################################################
function Remove_DB_User ($ServerName, $DatabaseName, $UserName)
{
$DeleteUserQuery=@"
DROP USER [`$(UserN)]
GO
"@

##Populates Arrays using SQL Queries above
$Drop_Param = "UserN=" + $UserName
try 
    {
    invoke-sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $DeleteUserQuery -Variable $Drop_Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }
if ($sqlerr -ne $null)
    {
    $errorReturn = Write-output ("Error while trying to remove " + $UserName + " from " + $DatabaseName + " on " + $ServerName + "`t") $SQLErr 
    }
else 
    {
    $errorReturn = write-output ("The user " + $UserName + " has been removed from " + $DatabaseName + " on " + $ServerName + "`t")
    }
return $errorReturn
}
#Test Usage
#$$err = Remove_DB_User "teller3" "Marty_test" "tpatel8"


###############################################################
# This function removes a Login from a SQL server
# It returns whatever error occurs on the command
###############################################################
function Remove_SQL_Login ($ServerName, $UserName)
{
$DeleteUserQuery=@"
DROP LOGIN [`$(UserN)]
GO
"@

##Populates Arrays using SQL Queries above
$DBName = "master"
$Drop_Param = "UserN=" + $UserName
try 
    {
    invoke-sqlcmd -ServerInstance $ServerName -Database $DBName -Query $DeleteUserQuery -Variable $Drop_Param -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }
if ($sqlerr -ne $null)
    {
    $errorReturn = Write-output ("Error while trying to remove The Login " + $UserName + " on " + $ServerName + "`t") $SQLErr
    }
else 
    {
    $errorReturn = write-output ("The Login " + $UserName + " has been removed from " + $ServerName + "`t") 
    }
return $errorReturn
}
#Test Usage
#$$err = Remove_User "teller3" "tpatel8"



#########################################################################
# This function tests to see if an account with the specified name is on
# a database. It will return 1 if it exists, and 0 if it does not
#########################################################################
function Check_DB_User ($ServerName, $DatabaseName, $UserName)
{
$CheckUserQuery=@"
SELECT NAME FROM sys.database_principals
WHERE type != 'R' AND [name] = `$(UserN)
"@

$CheckParam = "UserN='" + $UserName + "'"
try
    {
    $userlist = invoke-sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CheckUserQuery -Variable $CheckParam -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }

if ($userlist -eq $null)
    {
    return 0
    }
else 
    {
    return 1
    }
}


#########################################################################
# This function tests to see if an account with the specified name is on
# the server. It will return 1 if it exists, and 0 if it does not
#########################################################################
function Check_SQL_Login ($ServerName, $UserName)
{
$CheckLoginQuery=@"
SELECT NAME FROM master..syslogins
WHERE [name] = `$(UserN)
"@

$DatabaseName = "master"
$CheckParam = "UserN='" + $UserName + "'"
try
    {
    $userlist = invoke-sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CheckLoginQuery -Variable $CheckParam -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }

if ($userlist -eq $null)
    {
    return 0
    }
else 
    {
    return 1
    }
}


##########################################################
# This function takes a username and returns an array of 
# variations of that name on a database. Either the base name,
# a hostname\version or a domain\version. It returns 0 if none are found.
##########################################################
function Get_DB_Users ($ServerName, $DatabaseName, $UserName)
{
$CheckUserQuery=@"
SELECT NAME FROM sys.database_principals
WHERE type != 'R' AND [name] = `$(UserN) OR [name] like `$(UserWild)
"@ 

$NameParam = "UserN='" + $UserName + "'"
$WildParam = "UserWild='%\" + $UserName + "'"
$CheckParam = $NameParam, $WildParam

try
    {
    $userlist = invoke-sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CheckUserQuery -Variable $CheckParam -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }

if ($userlist -eq $null)
    {
    return 0
    }
else 
    {
    return $userlist
    }
}


##########################################################
# This function takes a username and returns an array of 
# variations of that name on a database. Either the base name,
# a hostname\version or a domain\version. It returns 0 if none are found.
##########################################################
function Get_SQL_Logins ($ServerName, $UserName)
{
$CheckLoginQuery=@"
SELECT NAME FROM master..syslogins
WHERE [name] = `$(UserN) OR [name] like `$(UserWild)
"@

$NameParam = "UserN='" + $UserName + "'"
$WildParam = "UserWild='%\" + $UserName + "'"
$CheckParam = $NameParam, $WildParam
$DatabaseName = "master"

try
    {
    $userlist = invoke-sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $CheckLoginQuery -Variable $CheckParam -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }

if ($userlist -eq $null)
    {
    return 0
    }
else 
    {
    return $userlist
    }
}


###########################################################
# This function returns the list of databases on a server
# if there are no results (error) it returns 0
###########################################################
function GET_DB_LIST ($ServerName)
{
$GetDBQuery=@"
SELECT name
FROM master.dbo.sysdatabases
"@ 

try
    {
    $DBList = invoke-sqlcmd -ServerInstance $ServerName -Database "master" -Query $GetDBQuery -ErrorVariable sqlerr -ErrorAction SilentlyContinue
    }
catch
    {
    }
if ($DBList -eq $null)
    {
    return 0
    }
else 
    {
    return $DBList
    }
}

####################################################################
# This function loops through the databases on a server, removes the 
# databases with the supplied name. If the -all flag is set then
# the server will use a wildcard to remove all *\username instances
####################################################################
function DB_PURGE ($ServerName, $UserName, [switch] $all)
{
    $RemoveMessage = new-object system.collections.arraylist
    $DBList = GET_DB_LIST $ServerName
    if ($DBList -ne 0) 
    {
        foreach ($DB in $DBlist)
        {
            if ($all)
            {
                $userlist = Get_DB_Users $ServerName $DB.Name $UserName
                if ($userlist -ne 0)
                {
                    foreach ($user in $userlist)
                    {
                        $UserTest = Check_DB_User $ServerName $DB.name $user.name
                        if ($UserTest -eq 1)
                        {
                             $RemoveMessage.Add((Remove_DB_User $ServerName $DB.name $user.name)) > $null
                        } 
                    } 
                } 
            } 
            else
            {
                $UserTest = Check_DB_User $ServerName $DB.name $UserName
                if ($UserTest -eq 1)
                {
                        $RemoveMessage.Add((Remove_DB_User $ServerName $DB.name $UserName)) > $null
                }
            }
        }
    }
    return $RemoveMessage
}

####################################################################
# This function removes a SQL Server Login from a server
# It will return with a message saying it was done or an error if one 
# was generated. 
####################################################################
function Purge_Login ($ServerName, $UserName, [switch] $all)
{
    $RemoveMessage = new-object system.collections.arraylist
    if ($all)
    {
        $LoginList = Get_SQL_Logins $ServerName $UserName
        if ($Loginlist -ne 0)
        {
            foreach ($Login in $Loginlist)
            {
                $LoginTest = Check_SQL_Login $ServerName $Login.name
                if ($LoginTest -eq 1)
                {
                    $RemoveMessage.Add((Remove_SQL_Login $ServerName $Login.name)) > $null
                } 
            } 
        }
    }
    else
    {
        $LoginTest = Check_SQL_Login $ServerName $UserName
        if ($LoginTest -eq 1)
        {
            $RemoveMessage.Add((Remove_SQL_Login $ServerName $UserName)) > $null
        }
    }
    return $RemoveMessage
}


#######################################################################
# This function sends an email to the Specified recipient that returns 
# The status message generated from running the executables. 
#######################################################################
function SendEmail ($body, $Recipient)
{
    
    $smtpServer = "Server"
    $smtpFrom = "SQL@email.com"
    $messageSubject = "Account Removal Report"
    $smtpTo = $Recipient
    send-mailmessage -from "$smtpFrom" -to "$smtpTo" -subject "$messageSubject" -body "$body" -smtpServer "$smtpserver"

}


#######################################################################
# This Function Loops through the servers in the server file and 
# removes the accounts from the SQL instances and DBS and sends email
# report
#######################################################################
function AccountRemoval ($UserName, $file = "C:\serverlist.txt", [switch]$all, $serverArray = ($server1, $server2), [switch]$list, $mailTo = "Torsten_Spooner@rush.edu")
{
    $mailMessage = new-object system.collections.arraylist
    if ($list)
    {
        If ($all)
        {
            foreach ($Server in $serverArray) 
            {
               $mailMessage += (DB_PURGE $Server $UserName -all)
               $mailMessage += (Purge_Login $Server $UserName -all)
            }
        }
        else 
        {
            foreach ($Server in $serverArray) 
            {
               $mailMessage += (DB_PURGE $Server $UserName)
               $mailMessage += (Purge_Login $Server $UserName)
            }
        }
    }
    else 
    {
        $serverArray = get-content $file
        If ($all)
        {
            foreach ($Server in $serverArray) 
            {
               $mailMessage += (DB_PURGE $Server $UserName -all)
               $mailMessage += (Purge_Login $Server $UserName -all)
            }
        }
        else 
        {
            foreach ($Server in $serverArray) 
            {
               $mailMessage += (DB_PURGE $Server $UserName)
               $mailMessage += (Purge_Login $Server $UserName)
            }
        }
    }
    
    $body = $mailMessage | out-string
    
    
    if ([string]::IsNullOrEmpty($body))
    {
        $body = "The DB Account Purge job was run, but did not appear to do anything. Please check the settings and try running it again."
    }
    else 
    {
        $body = write-output ("The DB Account Was run on " + (Get-date) + " by " + $env:USERNAME + " from " + $env:COMPUTERNAME + "`t") "The following occured:`n" $body
    }
    sendEmail $body $mailTo
}   


##################################################################################################

AccountRemoval $UserName -all -file $listlocation -mailto $emailAddress



