# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE :

#LOGGING
$SCRIPTNAME ="Something"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS
$OutputCsv = "C:\TEMP\$SCRIPTNAME_$DATETIME.csv"

#GRAPH API INFORMATION
$TenantId     = ""
$ClientId     = ""
$ClientSecret = ""


#CONNECT TO GRAPH

$SecureSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force

$ClientCredential = New-Object System.Management.Automation.PSCredential (
    $ClientId,
    $SecureSecret
)

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientSecretCredential $ClientCredential `
    -NoWelcome

$Results = @()

# GET ALL SHAREPOINT SITES
Write-Host "Retrieving all SharePoint sites..."
$Sites = Get-MgSite -All 
Write-Host "Sites found: $($Sites.Count)" -ForegroundColor Green

# RECURSIVE FUNCTION

function Get-DriveItemsRecursive {
    param (
        [string]$DriveId,
        [string]$ItemId,
        [string]$CurrentPath
    )

    try {
        $items = Get-MgDriveItemChild `
            -DriveId $DriveId `
            -DriveItemId $ItemId `
            -All
    }
    catch {
        Write-Warning "Skipping item (not a folder): $CurrentPath"
        return
    }

    foreach ($item in $items) {

        $itemPath = "$CurrentPath/$($item.Name)"

        # FILE
        if ($item.File) {
            [PSCustomObject]@{
                FileName   = $item.Name
                FullPath   = $item.WebUrl
                PathLength = $item.WebUrl.Length
                SizeMB     = [Math]::Round($item.Size / 1MB, 2)
                Modified   = $item.LastModifiedDateTime
            }
        }

        # FOLDER → recurse
        elseif ($item.Folder) {
            Get-DriveItemsRecursive `
                -DriveId $DriveId `
                -ItemId $item.Id `
                -CurrentPath $itemPath
        }
    }
}

# PROCESS SITES

foreach ($Site in $Sites) {
    Write-Host "Processing site: $($Site.WebUrl)"

        $drives  = Get-MgSiteDrive -SiteId $site.Id

        foreach ($drive in $drives) {
            Write-Host "Scanning library:" $drive.Name

            $Results += Get-DriveItemsRecursive `
                -DriveId $drive.Id `
                -ItemId "root" `
                -CurrentPath $drive.Name
        }

}

$Results |
    Sort-Object PathLength -Descending |
    Export-Csv $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: $OutputCsv"

Stop-Transcript