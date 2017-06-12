function Get-FSMORole {
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline=$True)]
    [string[]]$DomainName = $env:USERDOMAIN
  )
  BEGIN {
    Import-Module ActiveDirectory -Cmdlet Get-ADDomain, Get-ADForest -ErrorAction SilentlyContinue
  }
  PROCESS {
    foreach ($domain in $DomainName) {
      Write-Verbose "Querying $domain"
      Try {
      $problem = $false
      $addomain = Get-ADDomain -Identity $domain -ErrorAction Stop
      } Catch { $problem = $true
      Write-Warning $_.Exception.Message
      }
      if (-not $problem) {
        $adforest = Get-ADForest -Identity (($addomain).forest)
        New-Object PSObject -Property @{
          InfrastructureMaster = $addomain.InfrastructureMaster
          PDCEmulator = $addomain.PDCEmulator
          RIDMaster = $addomain.RIDMaster
          DomainNamingMaster = $adforest.DomainNamingMaster
          SchemaMaster = $adforest.SchemaMaster
        }
      }
    }
  }
}