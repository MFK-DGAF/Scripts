cls
$file1 = Read-host "Enter first file to combine include path :"
$file2 = Read-Host "Enter second file to combine include path:"
$file3 = Read-Host "Enter result filename include path & ext :"
get-content $file2 |
    select -Skip 1 |
    set-content "$file-temp"
move "$file-temp" $file2 -Force

New-Item -ItemType file $file3
$file_recs1 = Get-Content $file1
$file_recs2 = Get-Content $file2
Add-Content $file3 $file_recs1
Add-Content $file3 $file_recs2
