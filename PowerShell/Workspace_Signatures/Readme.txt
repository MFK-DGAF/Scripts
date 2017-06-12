There are two applications in this directory: 

inputprogram.ps1 
SignatureFixApp.ps1


inputprogram generates a group of 5 signature files in different colors for the person who's information is put in. There is logic in it to create files for the OBT office and unfinished logic for the generation of special signatures with office hours in it. 

There are defaults in place for a few of the items, so you don't always have to type out the information. 

The source directory defaults to the Workplace_signatures directory in Torsten's My Documents folder. If you are running this repeatedly from somewhere else, it would make sense to edit the code to change that default to where you are running it from. 

Inside the source directory are Template files for the WestGate (Template-Color.htm) and Oakbrook Terrace (TemplateOBT-Color.htm) locations, as well as directories that contain the necesary image and xml files. 




SignatureFixApp takes a list of workstation names via text file (in /images/) and replaces the images in the signatures with files that are the recommended bit depth and size (as well as the proper linked in icon) and resized them for ever user profile with signatures on every pc in the ServerList.txt file. 

Eventually, this functionality should be replaced by a InputProgram that uses a repaired (improved) template file. 
