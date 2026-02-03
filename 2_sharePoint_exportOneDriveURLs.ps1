﻿# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE :
#Exports all -my.sharepoint.com/personal/ URLS for review. Probably for use with the SharePoint Migration Tool

#LOGGING
$SCRIPTNAME ="exportOneDriveURL"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS

$TenantUrl = Read-Host "Enter the SharePoint admin center URL"

Connect-SPOService -Url $TenantUrl

$Export = "C:\TEMP\OneDriveURLs.log"


Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select -ExpandProperty Url | Out-File $Export -Force

Write-Host "Done! File saved as $($Export)."


Stop-Transcript