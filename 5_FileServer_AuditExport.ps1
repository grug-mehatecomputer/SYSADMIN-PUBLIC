﻿# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Filtered Export / Audit of a FileShare, 3 folders deep to flag items for further review.

#LOGGING
$SCRIPTNAME ="AFileShare_Audit"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\Temp\FileShare_Audit_$DATETIME\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS

$TargetPath = "D:\Shares"


#Create Folder for Audit Exports
$ReportFolder = "C:\Temp\FileShare_AUDIT_$DATETIME"
New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null

$TopLevelCsv = Join-Path $ReportFolder "TopLevelFolders.csv"
$PermsCsv    = Join-Path $ReportFolder "FolderPermissions.csv"



# Explicit exclusions
$ExcludedAccounts = @(
    "CREATOR OWNER",
    "SYSTEM",
    "Everyone"
)

$Assignments = $Acl.Access |
    Where-Object {
        $Identity = $_.IdentityReference.Value

        # Exclude computer objects
        $Identity -notmatch '\$$' -and

        # Exclude exact matches
        $ExcludedAccounts -notcontains $Identity -and

        # Exclude any BUILTIN account
        $Identity -notmatch '^BUILTIN\\' -and

        # Exclude local/domain Administrator accounts
        $Identity -notmatch '\\Administrator$' -and

        # Exclude common admin groups
        $Identity -notmatch '(^|\\)(Domain Admins|Enterprise Admins|Schema Admins)$' -and

        # Exclude Domain Users
        $Identity -notmatch '(^|\\)Domain Users$' -and

        # Exclude Everyone (some systems record as SID)
        $Identity -ne 'Everyone' -and
        $Identity -ne 'S-1-1-0'
    } |
    Select-Object -Unique |
    ForEach-Object {
        "$($_.IdentityReference.Value) [$($_.FileSystemRights)]"
    }

# ----------------------------------------------------------------------
# Export TopLevelFolders.csv
# ----------------------------------------------------------------------
Get-ChildItem -Path $TargetPath -Directory |
    Select-Object @{
        Name = "FolderName"
        Expression = { $_.Name }
    }, @{
        Name = "FilePath"
        Expression = { $_.FullName }
    } |
    Export-Csv -Path $TopLevelCsv -NoTypeInformation

# -------------------------------

# ----------------------------------------------------------------------
# Collect folders up to 3 levels deep
# ----------------------------------------------------------------------
$Folders = @()

# Level 0 (root)
$Folders += Get-Item $TargetPath

# Level 1
$L1 = Get-ChildItem $TargetPath -Directory -ErrorAction SilentlyContinue
$Folders += $L1

# Level 2
$L2 = foreach ($Folder in $L1) {
    Get-ChildItem $Folder.FullName -Directory -ErrorAction SilentlyContinue
}
$Folders += $L2

# Level 3
$L3 = foreach ($Folder in $L2) {
    Get-ChildItem $Folder.FullName -Directory -ErrorAction SilentlyContinue
}
$Folders += $L3

$Folders = $Folders | Sort-Object FullName -Unique

# ----------------------------------------------------------------------
# Export FolderPermissions.csv
# ----------------------------------------------------------------------
$Results = foreach ($Folder in $Folders) {

    try {
        $Acl = Get-Acl $Folder.FullName

        $InheritanceStatus = if ($Acl.AreAccessRulesProtected) {
            "Disabled"
            }
            else {
            "Enabled"
            }

    $Assignments = $Acl.Access |
    Where-Object {

        $Identity = $_.IdentityReference.Value

        # Always include DENY permissions
        if ($_.AccessControlType -eq 'Deny') {
            return $true
        }

        # Exclude computer objects
        $Identity -notmatch '\$$' -and

        # Explicit exclusions
        $ExcludedAccounts -notcontains $Identity -and

        # Exclude NT AUTHORITY
        $Identity -notmatch '^NT AUTHORITY\\' -and

        # Exclude all BUILTIN groups
        $Identity -notmatch '^BUILTIN\\' -and

        # Exclude administrator accounts
        $Identity -notmatch '\\Administrator$' -and

        # Exclude administrative groups
        $Identity -notmatch '(^|\\)(Domain Admins|Enterprise Admins|Schema Admins|Group Policy Creator Owners)$' -and

        # Exclude common domain groups
        $Identity -notmatch '(^|\\)(Domain Users|Domain Computers|Authenticated Users)$' -and

        # Exclude other default groups
        $Identity -notmatch '(^|\\)(Users|Guests|Pre-Windows 2000 Compatible Access)$' -and
        $Identity -notmatch '(^|\\)(Account Operators|Server Operators|Print Operators|Backup Operators)$' -and

        # Exclude Everyone
        $Identity -notmatch '^Everyone$' -and
        $Identity -ne 'S-1-1-0'
    } |
ForEach-Object {

    $Rights = ($_.FileSystemRights.ToString() -split ',\s*' |
        Where-Object { $_ -ne 'Synchronize' }) -join ', '

    "$($_.IdentityReference.Value) [$($_.AccessControlType): $Rights]"
}

        $PermissionOutput = if ($Assignments.Count -gt 0) {
        $Assignments -join '; '
        }
        else {
            'No Permissions Flags'
        }


        [PSCustomObject]@{
            FilePath                  = $Folder.FullName
            FolderName                = $Folder.Name
            Inheritance               = $InheritanceStatus
            "Permissions Assignments" = $PermissionOutput
        }
    }
    catch {
        [PSCustomObject]@{
            FilePath                 = $Folder.FullName
            FolderName               = $Folder.Name
            Inheritance              = "ERROR"
            "Permissions Assignments" = "ERROR: $($_.Exception.Message)"
        }
    }
}

$Results | Export-Csv -Path $PermsCsv -NoTypeInformation

Stop-Transcript