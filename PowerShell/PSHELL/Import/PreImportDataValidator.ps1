# ------------------------------------------------------------------------------------
# RUSH-HEALTH 2015
# This script with read file and loop to all lines and alert an errors if there is/are
# according to the facility configuration setting.
# LAST UPDATE: 12/11/2015 - check delimiter count in every lines
#------------------------------------------------------------------------------------- 
cls
$today_date = get-date
$monthdt = $today_date.Month
$daydt = $today_date.day

# get the configuration file.
#$code = read-host -prompt 'Enter client [example: RPS-OAK1-CMC] code'
#-------------------- list box ----------------------------------
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Computer"
$objForm.Size = New-Object System.Drawing.Size(300,230) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown(
	{
		if ($_.KeyCode -eq "Enter"){
			$x=$objListBox.SelectedItem;$objForm.Close()
		}
	}
)
$objForm.Add_KeyDown(
	{
		if ($_.KeyCode -eq "Escape") 
		{
			$objForm.Close()
		}
	}
)

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,140)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click(
	{
		$x=$objListBox.SelectedItem;$objForm.Close()
	}
)
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,140)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click(
	{
		$objForm.Close()
	}
)
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select a Facility:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 100

[void] $objListBox.Items.Add("RPS-RUMC")
[void] $objListBox.Items.Add("OAK1-OakPark")
[void] $objListBox.Items.Add("CMC-Copley")
[void] $objListBox.Items.Add("RMC-Riveside")
[void] $objListBox.Items.Add("987-Affiliated Radiology")
[void] $objListBox.Items.Add("787-Circle Imaging")
[void] $objListBox.Items.Add("332-Midwest Ortho")
[void] $objListBox.Items.Add("719-Univ Anesthes")
[void] $objListBox.Items.Add("638-University Pathology")
[void] $objListBox.Items.Add("118-Illinois Retina")
[void] $objListBox.Items.Add("815-UroPartners")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown(
	{
		$objForm.Activate()
	}
)
[void] $objForm.ShowDialog()
write-host "---" $x "----"
if ($x -eq ""){exit}

$code = $x.split('-')[0]
$code
#-------------------------end list box --------------------
exit
$varsfile = 'C:\PSHELL\FILECONFIG\CLIENTCODE_'+$code+'.txt'
$recs = get-content $varsfile
$array_recs = $recs[0].split(']')
$c_faccode  = $array_recs[0]
$c_sqlvars  = $array_recs[1]
$c_filecount = $array_recs[2]
$c_fileext   = $array_recs[3]
$c_delimiter_type = $array_recs[4]
$c_runtimedir= $array_recs[5]
$c_header    = $array_recs[6]
$c_error_rpt = $array_recs[7]+$daydt+$monthdt+'.txt'
$c_start_str = $array_recs[8]
$c_configrecs= (Get-Content $varsfile | Measure-Object)
$c_numlines  = $c_configrecs.Count - 1
$hashTable=$null
$hashTable=@{}  

# get all files into the $listfiles variables.
# and populate into the hash table for easy access.
$listfiles = Get-ChildItem $c_runtimedir $c_fileext -NAME
$file_counter=0
foreach($file in $listFiles) {
    $file_len=$file.length
    if ($file -match "import") {break} 
    if ($hashTable.ContainsKey($file)){
        #  table has it.
    }
    else {
        if ($c_faccode -eq "638") {
            if ($file -match "payment"){
                $payment638file = $file
            }
            if ($file -match "charge"){
                $charge638file = $file
            }
        }

        for($i=1; $i -le $c_numlines; $i++){
            $specs_recs = $recs[$i].split(']')
            if ($file.Substring($c_start_str,($specs_recs[0].length)) -eq  $specs_recs[0]) {
                $hashTable.Add($file,$i)
                write-host $file $i $specs_recs[0].length $specs_recs[0]
                break
            }
        }
    }
}

$hashTable
exit

# copley and Riveside transaction code edit.
# run a stored prodecure to get the list of transaction codes and assigned to dataset.
$notifywho=""
if ($code -eq "CMC" -Or $code -eq "RMC"){
    $notifywho='notify: Terry Wilson'
    $SQLServer = $c_sqlvars.split('!')[0]
    $SQLDBName = $c_sqlvars.split('!')[1]
    $SQLStoredProc = $c_sqlvars.split('!')[2]
    $SqlQuery = ‘EXEC '+$SQLStoredProc
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = “Server=$SQLServer;Database=$SQLDBName;Integrated Security=True”
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()

    $hash_xref = $null
    $hash_xref = @{} 
     
    if ($code -eq "CMC") { 
        foreach ($row in $DataSet.Tables[0].Rows)
        {
            $data_ref_id = $row[0].ToString().Trim()
            $charge_num = $row[1].ToString().Trim()
            if ($charge_num -ne ''){
                if ($hash_xref.ContainsKey($charge_num)){}
    	        else {
    		      $hash_xref.Add($charge_num, $data_ref_id)
    	        }
            }
        }
    }
    if ($code -eq "RMC") {
        $xcount=0
        foreach ($row in $DataSet.Tables[0].Rows){
            $data_code = $row[0].ToString().Trim()
            $xcount += 1
            $hash_xref.add($data_code,$xcount)
        }
        $hash_xref
    }
        
    $hash_codetbl = $null
    $hash_codetbl = @{}
}

#-- 638 service date edit --------------------------------------
# this will create a corrected file if invalid servide date is equal "//0"
if ($code -eq "638"){
   $hash_svcdate = $null
   $hash_svcdate = @{} 
   if ($payment638file -ne $null) {
		$filename = $c_runtimedir+"\"+$payment638file
		$univ_reader=[System.IO.File]::OpenText($filename)
		try {
			for(;;) {
				$line = $univ_reader.ReadLine()
				if ($line -eq $null) { break }
				$splitedstring=$line.split("|") 
				$Episode      = $splitedstring[0].Replace('"',"") 
				$ServiceDate  = $splitedstring[7].Replace('"',"")  
				$result = $ServiceDate.Contains('//')
				if ($result) {
					if ($hash_svcdate.ContainsKey($Episode)) {
						# -- Write-Host "already added!" $Episode
					}
					else {
						$hash_svcdate.Add($Episode,$ServiceDate)
						$counter+=1
					}
				}
			}
		}   
		finally {
			$univ_reader.Close()
		}
        
# check hash table if it found "//0" service date.        
        if ($hash_svcdate.count -gt 0){
#--- 638 charge file
		$filename = $c_runtimedir+"\"+$charge638file
		$readerchg=[System.IO.File]::OpenText($filename)
		try {
			for(;;) {
				$line = $readerchg.ReadLine()
				if ($line -eq $null) { break }
				$splitedstring=$line.split("|") 
				$Episode      = $splitedstring[0].Replace('"',"") 
				$ServiceDate  = $splitedstring[19] 				  
				if ($hash_svcdate.ContainsKey($Episode)){
					if ($hash_svcdate[$Episode].Contains("//")) {
						$hash_svcdate.Set_Item($Episode,$ServiceDate)
					}
 				}
			}
		}   
		finally {
			$readerchg.Close()
		}
#------------------------------------------------------------------------
# once we have the hash table populate with service date according to the
# episode number as a key then loop again to the payment file to complete
# the process.
#------------------------------------------------------------------------ 
		$filename = $c_runtimedir+"\"+$payment638file
		$readerpymt=[System.IO.File]::OpenText($filename)
		$resultfile = $c_runtimedir+"\resultpayment638file.txt"
		try {
			for(;;) {
				$line = $readerpymt.ReadLine()
				if ($line -eq $null) { break }
				$splitedstring=$line.split("|") 
				$Episode = $splitedstring[0]
				$ServiceDate  = $splitedstring[7] 
				$result = $ServiceDate.Contains('//')
				if ($result) {
					$tempid = $Episode.Replace('"',"")
					if ($hash_svcdate.ContainsKey($tempid)) {
						$splitedstring[7] = $hash_svcdate.Get_Item($tempid)
						Write-Host "---> service date //0 had been changed to " $splitedstring[7] " for this pid " $tempid
					}
				}
				# join them all together--------------
				$rec = [string]::join('|',$splitedstring)
				Add-Content $resultfile $rec
			}
		}
		finally {
			$readerpymt.Close()
		}
        }
	}  
}
##--------------------------------------------------------------------
##-starting the edit process:
## loop into all the lines and do some edits.  A progress bar will show
## the process percentage.
##--------------------------------------------------------------------
$filecnt = 1
$percnt = [int](100 / $c_filecount)

foreach ($hkey in $hashTable.keys) {
    write-host $hkey
    $filecnt += $percnt
    if ($filecnt -lt 100){
        write-progress -activity "$c_faccode $hkey Edit search in Progress" -status "$filecnt% Complete:" -percentcomplete $filecnt;
    }

    $counter =0   
    $c_linenum = $hashTable.$hkey
    $filename = $c_runtimedir+"\"+$hkey
    $readrecs=[System.IO.File]::OpenText($filename)
    try {
        if ($c_header -match "WITH_HEADER"){
            $line = $readrecs.ReadLine()
            $counter += 1
        } 
        $edit_count = $recs[$c_linenum].split(']').count
        $edit_recs = $recs[$c_linenum].split(']')
	    $num_delimiter = $edit_recs[1]
        $value_skip = $edit_recs[0]
        for(;;) {
            $line = $readrecs.ReadLine()
            if ($line -eq $null ) { break }
            if ($line.length -lt 5) { break }
            $line_recs=$line.split($c_delimiter_type)
            $DelimCount = ([char[]]$line -eq $c_delimiter_type).count
            $error_rec = $null
            $counter += 1 
            $acct_code = $recs[0] 
            
            #check the file delimiter in every line
            if ($num_delimiter -ne $null) {
                if ($num_delimiter -ne $DelimCount) {
                    $error_rec = 'missing or more delimiter '+$hkey+'; line num:'+ $counter
                    Add-Content $c_error_rpt $error_rec 
                }
            }           

#write-host $num_delimiter $DelimCount $c_linenum
#break;
            # edit every field according the config file.
            $val = 1
            while($val -ne $edit_count) {
                $error_rec = $null
                $fldrecs = ''
                $val+=1
                if ($edit_recs[$val] -ne $null) {
                    $fldrecs = $edit_recs[$val]
                    if ($fldrecs -ne $null) {
                        $fldrecs = $fldrecs.split('!')
                        $fldtoedit = $fldrecs[0]
                        $fldnum    = $fldrecs[1]
                        $value_edit = $line_recs[$fldnum]
                        if ($value_edit) {$value_edit=$value_edit.replace('"',"")}
                        $error_ext = $hkey + ',line_num='+$counter +', value = '+$value_edit
                        switch ($fldtoedit) {
                            "acct_code" {
                                if (!$value_edit) {
                                    $error_rec = 'missing account code'
                                }
                                else {
                                    if ($value_edit.trim(' ') -ne $c_faccode) { 
                                        $error_rec = 'invalid account code' 
                                    }
                                }
                            }
                            
                            "last_name" { 
                                if (!$value_edit) { $error_rec = 'missing last name' }
                            }
                            
                            "first_name" { 
                                if (!$value_edit) { $error_rec = 'missing first name' }
                            }
                            
                            "acct_code" {
                                if (!$value_edit) {
                                    $error_rec = 'missing account code'
                                }
                            else {
                                if ($value_edit.trim(' ') -ne $c_faccode) { 
                                    $error_rec = 'invalid account code' 
                                    }
                                }
                            }
                            "admit_date" {
                                if ($value_edit.trim() -ne '') {
                                    if ([datetime]$value_edit) {
                                        if ([datetime]$value_edit -gt $today_date){ 
                                            $error_rec ='invalid admit date'
                                        }  
                                    } 
                               }
                               else { 
                                    if ($value_edit.trim() -eq ''){
                                       if ($hkey -match 'inpt_mfile'){
                                         $error_rec = 'missing admit date on inpt clm'
                                       }
                                       if ($hkey -match 'outpt_mfile'){
                                         $error_rec = 'missing admit date on outpt claim'
                                       }
                                    }
                               }
                               
                            }
                            "ssn_edit" {
                               if ($value_edit -match '99999999'){
                                   $error_rec = 'invalid ssn'    
                               }
                               if ($value_edit -match '88888888'){
                                   $error_rec = 'invalid ssn'    
                               }
                               if ($value_edit -match '77777777'){
                                   $error_rec = 'invalid ssn'    
                               }
                               if ($value_edit -match '66666666'){
                                   $error_rec = 'invalid ssn'    
                               }
                               if ($value_edit -match '55555555'){
                                   $error_rec ='invalid ssn'    
                               }
                               if ($value_edit -match '44444444'){
                                   $error_rec ='invalid ssn'    
                               }
                               if ($value_edit -match '33333333'){
                                   $error_rec ='invalid ssn'    
                               }
                               if ($value_edit -match '22222222'){
                                   $error_rec ='invalid ssn'    
                               } 
                               if ($value_edit -match '11111111'){
                                   $error_rec ='invalid ssn'    
                               }                                                                
                            }

                            "check_future_dt" {
                                if (($value_edit.replace('"','')) -ne ''){
                                    if ([datetime]$value_edit -gt $today_date){ 
                                        $error_rec ='invalid admit date' 
                                    }
                                }
                            }
                        
                            "service_date" {
                                if ($value_edit -ne '') {
                                    if ($value_edit -match "//0") { 
                                        $error_rec = 'invalid service date' 
                                    }
                                    if ([datetime]$value_edit){
                                        if ([datetime]$value_edit -gt $today_date){
                                            $error_rec = 'invalid service date'
                                        }
                                    } else {
                                        $error_rec = 'no service date'
                                    }
                                    
                                }
                            
                            }
                            
                            "discharge_date" {
                                if ($value_edit -ne '') {
                                    if ([datetime]$value_edit){
                                        if ([datetime]$value_edit -gt $today_date){
                                            $error_rec = 'invalid discharge date - not future date?'
                                        }
                                    }
                                }
                            
                            }
                            
                            "stmt_from_stmt_to_date"{
                                if ($value_edit -ne '') {
                                   if ([datetime]$value_edit) {
                                       if ([datetime]$value_edit -gt $today_date){
                                            $error_rec = 'invalid statement from date - not future date?'
                                       }
                                       if ($fldrecs[3] -ne ''){
                                           $val2=$line_recs[($fldrecs[3])]
                                           if ([datetime]$val2 -lt [datetime]$value_edit){
                                                $error_rec = 'stmt_from cannot be greater than stmt_to'
                                           }
                                        }
                                   }
                       
                                }
                            }                            
                            
                            "check_numeric" {
                                if ($value_edit -match "[0-9]") {
                                } else {
                                    $error_rec='expecting numeric value'
                                }
                            } 
						   "checkvalid_date" {
                                if ($value_edit -ne '') {
                                    if (($value_edit -as [DateTime]) -ne $null) {} else {$error_rec='invalid date'}
                                }

						    }
                            "check_fld_len" {
                                $fldlen    = $fldrecs[2]
                                if ($value_edit.length -gt $fldlen) {
                                    $error_rec = 'string truncation?'
                                }
                            }
                            "rev_code" {
                                $fldlen    = $fldrecs[2]
                                $value_edit = $value_edit.trim(' ')
                                if ($value_edit.length -gt $fldlen) {
                                    $error_rec = 'string truncation?'
                                }                         
                            }
                            
                            "charge_amt" {
                                if ($value_edit.trim() -eq ''){
                                   if ($value_edit.trim() -eq '0'){
                                       $error_rec = 'charge amount may not be zero!'
                                   }
                                }
                            }
                         
                            "check_char" {
                                $patterns = '+' 
                                 foreach ($pattern in $patterns){
                                    if ($line -match "\$pattern") {$error_rec = 'invalid character data'}
                                 }
                            }
                            "default_value" {
                                if ($value_edit -ne $fldrecs[4]){ $error_rec = 'invalid data value'} 
                            }
                            "payment_code" {
			                    if ($hash_xref.Containskey(($value_edit.trim(' ')))) {
                                    #
                                } else {
                                     $error_rec = 'missing payment code'
                                }   
                            }
                         
						    "trans_code" {
							    if ($hash_xref.Containskey(($value_edit.trim(' ')))) {
		                          # already added and find?
						  	     }
							     else {
								      if ($line_recs[4].trim(' ') -ne 'C') {
			                              if ($hash_codetbl.ContainsKey($value_edit.trim(' '))) {
				                                #already have it!
			                              } else {
				                                $hash_codetbl.Add($value_edit.trim(' '),'-8888888')
                                                $error_rec = 'missing transcode' + ', ' + $notifywho
			                             }			
								    }
							     }
						      }
                           }
                           

                           
                            if ($error_rec) {
                                $error_rec = $error_rec + ', ' + $error_ext
                                Add-Content $c_error_rpt $error_rec 
                                #write-host $error_rec
                                $error_rec = ''
                            }
                        
                         
                        }
                    }
                } 
            }   
    }
    finally {
        $readrecs.Close()
    }
     
}
# evoke the error report
# this will pop up a notepad with the list of errors if there are any.
if ($c_error_rpt -ne $null) {
	if (Test-Path $c_error_rpt) {
		Invoke-Item $c_error_rpt
	}
}
# End of the script "Good luck!"