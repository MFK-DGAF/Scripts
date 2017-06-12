
param (
    $localPath = "c:\downloaded\",
    $remotePath = "/home/user/",
    $fileName = "download.txt"
)
         
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
    $sessionOptions.HostName = "example.com"
    $sessionOptions.UserName = "user"
    $sessionOptions.Password = "mypassword"
    $sessionOptions.SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Format timestamp
        $stamp = $(Get-Date -f "yyyyMMddHHmmss")
 
        # Download the file and throw on any error
        $session.GetFiles(
            ($remotePath + $fileName),
            ($localPath + $fileName + "." + $stamp)).Check()
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch [Exception]
{
    Write-Host $_.Exception.Message
    exit 1
}