#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -version 2.0

<#
 	.SYNOPSIS
        The PowerShell script which can be used to set the default printer.
    .DESCRIPTION
        The PowerShell script which can be used to set the default printer.
    .PARAMETER  TrustedSites
		Spcifies the trusted site in Internet Explorer.
    .EXAMPLE
        C:\PS> C:\Script\SetDefaultPrinter.ps1 -PrinterName "Microsoft XPS Document Writer"

		Successfully set the default printer.

        This command shows how to set "Microsoft XPS Document Write" as default printer.
    .EXAMPLE
        C:\PS> C:\Script\SetDefaultPrinter.ps1 -PrinterName "Microsoft XPS Document Writer" -Whaif

		What if: Performing the operation "Set the default printer" on target "Microsoft XPS Document Writer".

        When you executed this command with 'Whatif' parameter, it will show what would happen if you executed the command without actually executing the command.

#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param
(
    [Parameter(Mandatory=$true)]
    [String]
    $PrinterName
)

#Get the infos of all printer
$Printers = Get-WmiObject -Class Win32_Printer

If($PSCmdlet.ShouldProcess("$PrinterName","Set the default printer"))
{
    Try
    {
        Write-Verbose "Get the specified printer info."
        $Printer = $Printers | Where{$_.Name -eq "$PrinterName"}

        If($Printer)
        {
            Write-Verbose "Setting the default printer."
            $Printer.SetDefaultPrinter() | Out-Null

            Write-Host "Successfully set the default printer."
        }
        Else
        {
            Write-Warning "Cannot find the specified printer."
        }
    }
    Catch
    {
        $ErrorMsg = $_.Exception.Message
        Write-Host $ErrorMsg -BackgroundColor Red
    }
}