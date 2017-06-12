# This will clear all logs
Clear-EventLog -List | Foreach-Object {Clear-EventLog -Log $_.Log}