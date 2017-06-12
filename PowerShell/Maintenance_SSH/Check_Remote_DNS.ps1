function Check_Remote_DNS (
    [string]$Server = "SFTP.rush-health.com", 
    [string]$credDir = "E:\automation\Maintenance_SSH"
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
            ############################
            # hostName specified here!
            ############################
            $results = Invoke-SSHCommand -SSHSession $session -Command {[System.Net.Dns]::GetHostAddresses("ActiveWebDB").IPAddressToString } 
            if ($results.Output)
            {        
                $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 0; 'Value'=$results.Output})
            }
            else 
            {
                $errorMessage = write-output ("The servername " + $Server + " was unable to be resolved.")
                $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 1; 'Value'= $errorMessage})
            }
            $disconnect = $session.Disconnect
            $remove = Remove-SSHSession -SSHSession $session
        }
        else 
        {
            $errorMessage = write-output ("The servername " + $Server + " was unable to be resolved.")
            $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 1; 'Value'= $errorMessage})
        }
    }
    else 
    {
        $errorMessage = write-output ("The file " + $CredPath + " does not exist.")
        $ReturnValue = new-object -TypeName "PSObject" -Prop (@{'ErrorCode'= 1; 'Value'= $errorMessage})
    }
    return $ReturnValue

}