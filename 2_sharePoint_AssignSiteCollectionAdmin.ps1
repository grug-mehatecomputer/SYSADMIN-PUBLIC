﻿# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Bulk assign a site admin to sharepoint sites based on import from CSV

#LOGGING
$SCRIPTNAME ="Site Admin assignment"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#Import and Install Modules if required
#Install-Module -Name Microsoft.Online.SharePoint.PowerShell
#Import-Module Microsoft.Online.SharePoint.PowerShell

#SCRIPT VARS
$AdminUrl = "https://contoso-admin.sharepoint.com" # Replace with your tenant's admin URL
$CsvPath = "c:/file/path.csv"# Replace with your CSV file path
$UserAdmin = "User@contoso.com"# The account getting admin rights

#Connect-SPOService -Url $AdminUrl


# 4. Import CSV and loop through each site
$Sites = Import-Csv -Path $CsvPath

foreach ($Site in $Sites) {
    Write-Host "Adding admin to: $($Site.SiteUrl)" -ForegroundColor Cyan
    try {
        # Set-SPOUser adds the user to the Site Collection Admin group
        Set-SPOUser -Site $Site.SiteUrl -LoginName $UserAdmin -IsSiteCollectionAdmin $true -ErrorAction Stop
        Write-Host "Successfully added admin to $($Site.SiteUrl)" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to add admin to $($Site.SiteUrl). Error: $_"
    }
}

Stop-Transcript