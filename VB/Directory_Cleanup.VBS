Const strPath = "\\RUSH-NAS\Data\IT_Data\FortiWeb_Backups"
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")
 
Call Search (strPath)
 
' Comment out below line if you'd like to use this script in windows schedule task
WScript.Echo"Done."
 
Sub Search(str)
    Dim objFolder, objSubFolder, objFile
    Set objFolder = objFSO.GetFolder(str)
    For Each objFile In objFolder.Files
 
        ' Use DateLastModified for modified date of a file
        If objFile.DateCreated < (Now() - 0) Then
            objFile.Delete(True)
        End If
 
    Next
    For Each objSubFolder In objFolder.SubFolders
        Search(objSubFolder.Path)
 
        ' Files have been deleted, now see if the folder is empty.
        If (objSubFolder.Files.Count = 0) Then
            objSubFolder.Delete True
        End If
 
    Next
End Sub
