@echo off
::variables
set backupdir=%USERPROFILE%\Desktop\savesbackup 
set backupcmd=xcopy /s /c /d /e /h /i /r /y

echo ### Backing Up Saves...
%backupcmd% "%USERPROFILE%\Desktop\saves" "%backupdir%\saves"

echo Backup Complete
@pause