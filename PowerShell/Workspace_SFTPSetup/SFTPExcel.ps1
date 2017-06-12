$Filepath = "K:\Information Technology\Documentation\SFTP\SFTP Account Tracking.xlsx"


$AccountName = "Oncology_Rush"
$Directory =  "E:\SFTP\Other\Oncology_Rush"
$Description = "SFTP account for Oncology people at Rush to send files to Theresa Burkhart"
$Contact = "Theresa Gubal"
$ContactEmail = "Theresa_J_Gubala@rush.edu"
$Local_Expert = "Theresa Burkhart"
$Frequency = "Intermittent"
$Last_Updated = Get-Date -Format MM/dd/yyyy


$objExcel=New-Object -ComObject Excel.Application
$objExcel.Visible=$true
if (Test-Path $FilePath) 
{
	$WorkBook=$objExcel.Workbooks.Open($FilePath)
	$Worksheet = $Workbook.Worksheets.Item(1)
	$introw = $Worksheet.UsedRange.Rows.Count + 1 
	$Worksheet.cells.item($introw, 1) = $AccountName 	
	$Worksheet.cells.item($introw, 2) = $Directory
      	$Worksheet.cells.item($introw, 3) = $Description
      	$Worksheet.cells.item($introw, 4) = $Contact 
	$Worksheet.cells.item($introw, 5) = $ContactEmail 	
	$Worksheet.cells.item($introw, 6) = $Local_Expert
      	$Worksheet.cells.item($introw, 7) = $Frequency
      	$Worksheet.cells.item($introw, 8) = $Last_Updated
	$WorkBook.Save()
	$WorkBook.Close()
	$objExcel.Quit()
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($objExcel)

}
else 
{
	write-host ("The Excel file you are triyng to write to:" + $filepath + " cannot be found")
}