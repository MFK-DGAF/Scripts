cls
$patterns = '+','-'
$lines = '118|1DJT|Tsatsoulis|Dimitra|J||MD+|Internal Medicine|'

 foreach ($pattern in $patterns){
    [regex]::matches($val,"\+") 
 }


 foreach ($pattern in $patterns){
    write-host $pattern
    #if ($lines -contains $pattern) {write-host 'invalid character'}
    #if ($lines -cmatch ("'\"+$pattern+"'")) {write-host '2'}
    if ($lines -match "\$pattern") {write-host '(' $pattern ') invalid'}
 }

