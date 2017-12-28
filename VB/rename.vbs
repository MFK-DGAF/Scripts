'Rename Files
'Created because Cigna puts a '.' in front of their file names.
'============
Dim objFSO, objFolder, strFile, intLength, firstOne, restofName, strNewName

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("e:\PracticeSFTP\automation\CignaACO")

For Each strFile in objFolder.Files

        'Use the Left function to get the first three characters of the filename
        firstOne = Left(strFile.Name,1)


	If firstOne = "." Then


        'Use the Mid function to get the rest of the filename
        restofName = Mid(strFile.Name,2)

	'Now replace it
        strNewName = "e:\PracticeSFTP\automation\CignaACO\" & restofName
        objFSO.MoveFile strFile.Path, strNewName

    End If
Next

