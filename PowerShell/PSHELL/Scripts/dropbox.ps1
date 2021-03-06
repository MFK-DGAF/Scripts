cls
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
$objLabel.Text = "Please select a computer:"
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

$x