[int]$xMenuChoiceA = 0
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 4 ){
Write-host "1. User tasks"
Write-host "2. Group tasks"
Write-host "3. Shared mailbox tasks"
Write-host "4. Quit and exit"
[Int]$xMenuChoiceA = read-host "Please enter an option 1 to 4..." }
Switch( $xMenuChoiceA ){
  1{<#run an action or call a function here #>}
  2{<#run an action or call a function here #>}
  3{<#run an action or call a function here #>}
default{<#run a default action or call a function here #>}
}