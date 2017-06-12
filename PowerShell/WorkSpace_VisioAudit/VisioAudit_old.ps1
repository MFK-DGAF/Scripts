$computer = "wg0501kp"
gwmi win32_softwareFeature -computername $computer | select-object productname, lastuse -unique | where {$_.productname -like "*Visio Pro*"}


