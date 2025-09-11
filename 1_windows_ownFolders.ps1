# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Hastly take ownership of a folder/file structure and grant administrators group full control.


#LOGGING
$SCRIPTNAME ="ownFolders"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS
$FilePath ="" #Insert Target File Path

#SCRIPT

takeown /F $FilePath
takeown /F $FilePath /r /d y
icacls $FilePath /grant Administrators:F
icacls $FilePath /grant Administrators:F /t


Stop-Transcript