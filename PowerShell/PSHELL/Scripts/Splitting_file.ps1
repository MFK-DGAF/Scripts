cls
$linecount  = 0
$filenumber = 1
$sourcefilename = Read-Host "Enter source file example c:\folder\..\filename.txt "
$destinationfolderpath = Read-Host "Enter destination path example c:\folder\folder "
$splitfilename = Read-Host "Enter split filename example test "

write-host "please wait while the line is being computed"
Get-Content $sourcefilename|Measure-Object|ForEach-Object {$sourcelinecount = $_.Count}
write-host 'sourcelinecount = '$sourcelinecount
$destinationfilesize = Read-Host "How many lines will be each new split file? "
$maxsize =[int]$destinationfilesize
write-host File is $sourcefilename - destination is $destinationfolderpath - new file line count will be $destinationfilesize

$line1 = Get-Content $sourcefilename | select -First 1
write-host $line1

$content = get-content $sourcefilename | % {
 Add-Content $destinationfolderpath\$splitfilename$filenumber.txt “$_”
  $linecount ++
  If ($linecount -eq $maxsize) {
    $filenumber++
    $linecount = 0
    
    Add-Content $destinationfolderpath\$splitfilename$filenumber.txt $line1
  }
}

#collect the poop of your pet
[gc]::collect()
#[gc]::WaitForPendingFinalisers()


