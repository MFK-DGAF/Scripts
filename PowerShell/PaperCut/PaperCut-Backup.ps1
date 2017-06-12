#Map Backup Share
net use /delete S: /yes
net use S: \\RHAPOLLO\PaperCut-Backups 11669335007 /user:RHAPOLLO\rha

#Copy the backups from server to nas
Copy-Item -Path S:\* -Destination "\\10.121.38.23\RHAPOLLO-Data" -Force

#Delete backup jobs older than 15 days
dir "\\10.121.38.23\RHAPOLLO-Data" -recurse | 
where { ((get-date)-$_.creationTime).days -gt 15 } | 
remove-item -force

net use /delete S: /yes

