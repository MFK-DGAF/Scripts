#compares two dates
cls
$val1 = "2015-08-20"
$val2 = "2015-08-15"

if ([datetime]$val1 -gt [datetime]$val2){
    write-host 'bad'
} else {
    write-host 'good'
}
