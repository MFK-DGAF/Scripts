cls
$file_count = get-childitem c:\css | measure-object -count
write-host $file_count