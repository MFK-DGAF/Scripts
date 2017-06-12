#These commands initialize, partition and format a disk for use. 
#It uses the second disk (Since the first would be the OS), and makes it the maximum size, using
#default values for offset and drive letter. 

Initialize-Disk -Number 1

New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter


#Below (format) only works if the drive letter is actually D
#To fully automate, pipe the data from the previous to this one, or set it to a varialbe, and use
# the $Variable.Driveletter to choose which drive to format

Format-Volume -DriveLetter D

##The command below sets the drive label to "Data"

set-volume -DriveLetter E -NewFileSystemLabel Data
