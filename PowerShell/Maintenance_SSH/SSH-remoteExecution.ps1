#function Get-remote 


function Run-Remote-Command (
    [string]$Server = "SFTP.rush-health.com", 
    [string]$credDir = "E:\automation\Maintenance_SSH",
    [string]$commandString
    )
{
    $CredPath = write-output ($credDir + "\Credentials_" + $env:USERNAME + ".xml")
    if (Test-Path $CredPath -ErrorAction SilentlyContinue)
    {
        if (-not(Get-Module -Name Posh-SSH))
        {
            import-module Posh-SSH
        }
        [xml]$CredInfo = Get-Content $CredPath
        $password =  ConvertTo-SecureString $CredInfo.root.Password
        $Creds = New-Object System.Management.Automation.PSCredential ($CredInfo.root.UserName, $password)
        $ServerIP  = [System.Net.Dns]::GetHostAddresses($Server).IPAddressToString
        if ($ServerIP)
        {
            if ($Serverip.GetType() -eq "array")
            {
                $ServerIP = $ServerIP[0]
            } 
            $session = New-SSHSession -Credential $Creds -ComputerName $Server -AcceptKey
            $commandScript = ConvertTo-Scriptblock $commandString
            $results = Invoke-SSHCommand -SSHSession $session -Command $commandScript 
            if ($results.Output)
            {        
                $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 0; 'Value'=$results.Output})
            }
            else 
            {
                $errorMessage = write-output ("The servername " + $Server + " was unable to be resolved.")
                $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 1; 'Value'= $errorMessage})
            }
        }
    }
    else
    {
        $errorMessage = write-output ("The file " + $CredPath + " does not exist.")
        $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 1; 'Value'= $errorMessage})
    }
    return $ReturnValue

}


function ConvertTo-Scriptblock  {
<#
 Function to Convert a String into a Script Block
#>
	Param(
        [Parameter(       
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$string 
        )
       $scriptBlock = [scriptblock]::Create($string)
       return $scriptBlock
}



function Get-ADUserObject (
    [string]$username, 
    [string]$ADServer = "Luigi-SPADFS2"
    )
    {
        [string]$CommandString = ""
         $Commandstring = Write-Output ("Get-ADUser -Filter {name -like '" + $UserName + "'}")
         $commandString = write-output ("invoke-command -ComputerName " + $ADServer + " -ScriptBlock {" + $CommandString + "}")  
         Run-Remote-Command -commandString $CommandString
    }


$test = Get-ADUserObject -username TestTor