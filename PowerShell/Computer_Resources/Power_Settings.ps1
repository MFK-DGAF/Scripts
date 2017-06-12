(gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter "ElementName ='Balanced'").Activate()

$aa = (gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter { ElementName ='Balanced'}).instanceid.split("\")[1]

$ba = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Hibernate after' }).instanceid.split("\")[1]
$bb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ba'")
$bb.settingindexvalue = 0
$bb.Put()

$ca = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Turn off hard disk after' }).instanceid.split("\")[1]
$cb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ca'")
$cb.settingindexvalue = 0
$cb.Put()

$da = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Turn off display after' }).instanceid.split("\")[1]
$db = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$da'")
$db.settingindexvalue = 1500
$db.Put()

$ea = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Allow hybrid sleep' }).instanceid.split("\")[1]
$eb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$ea'")
$eb.settingindexvalue = 0
$eb.Put()

$fa = (gwmi -NS root\cimv2\power -Class win32_PowerSetting -Filter { Elementname = 'Sleep after' }).instanceid.split("\")[1]
$fb = (gwmi -NS root\cimv2\power -Class win32_powersettingdataindex -Filter "InstanceID like '%$aa%ac%$fa'")
$fb.settingindexvalue = 0
$fb.Put()

gwmi -NS root\cimv2\power -Class win32_PowerPlan -Filter "ElementName ='Balanced'".Activate()