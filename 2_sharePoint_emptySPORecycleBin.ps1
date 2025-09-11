# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Empty the SharePoint Recyclebin on a specific site.
#REQUIREMENTS: PS 7, Module: PnP.Powershell, Registered App w/ SharePoint Delegate Permissions

#LOGGING
$SCRIPTNAME ="emptySPORecycleBin"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append


#SCRIPT VARS
$SiteURL = "https://TENANT.sharepoint.com/sites/SITENAME" #Replace with specific SharePoint Site
$ClientID = "000000-1111-2222-3333-4444444444" #Replace with registered app 'Client ID'

#SCRIPT




# Connect using Web-based Authentication
Write-Host "Connecting to SharePoint Online..."
Connect-PnPOnline -Url $SiteURL -ClientId $ClientID

# Verify connection
$Connection = Get-PnPConnection
if ($null -eq $Connection) {
    Write-Host -ForegroundColor Red "Authentication failed. Please try again."
    exit
}

# Function to Get Recycle Bin Size for the given site
Function Get-SPOSiteRecycleBinSize($SiteURL)
{ 
    Write-Host "Retrieving Recycle Bin items..."
    
    # Get First-Stage Recycle Bin Items
    $FirstStageItems = Get-PnPRecycleBinItem
    $FirstStageSize = ($FirstStageItems | Measure-Object -Property Size -Sum).Sum

    # Get Second-Stage Recycle Bin Items
    $SecondStageItems = Get-PnPRecycleBinItem -SecondStage
    $SecondStageSize = ($SecondStageItems | Measure-Object -Property Size -Sum).Sum

    Write-Host -ForegroundColor Green "Site Collection URL: $SiteURL"
    Write-Host -ForegroundColor Green "First Stage Recycle Bin Size: $([math]::Round($FirstStageSize/1MB, 2)) MB"
    Write-Host -ForegroundColor Green "Second Stage Recycle Bin Size: $([math]::Round($SecondStageSize/1MB, 2)) MB"
}

# Call the function for the specific site
Get-SPOSiteRecycleBinSize -SiteURL $SiteURL

Write-Host "Starting RecycleBin Clean Up"

Clear-PnPRecycleBinItem -All -Force

Write-Host "Completed RecycleBin Clean Up"

Get-SPOSiteRecycleBinSize -SiteURL $SiteURL

Stop-Transcript