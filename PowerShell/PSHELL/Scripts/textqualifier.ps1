cls
$delnum=2
$textqual='"'
$c_delimiter_type="|"
#$val1 ='"32104"|"32104/Admission Date ||"|"638"'
$val1='Transaction ID|Account Number|Detail Transaction Type|Insurance/Payer ID|Transaction Date|Payment Post Date|Copay|Coinsurance Amount|Deductible|Payment Amount|Payment Code|Payment Description|Denial Flag|Data Extract Run Date'
$DelimCount = ([char[]]$val1 -eq $c_delimiter_type).count
write-host $DelimCount
#$okval = "OK"
#if ($delnum -ne $DelimCount) {
#   if ($val1 -match $textqual){
#      $val3 = ([char[]]$val1 -eq $textqual).count
#      if ($val3 -eq ($delnum * 3)){
#         #
#      } else {
#         $okval= "not"
#      }
#   }
#}
#$okval

