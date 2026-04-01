# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Creates Reports in bulk for project work.

#LOGGING
$SCRIPTNAME ="AD_Audit"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\Temp\AD_AUDIT_$DATETIME\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS

#Create Folder for Audit Exports
$ReportFolder = "C:\Temp\AD_AUDIT_$DATETIME"
New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null


#Report of Home Directories
Get-ADUser -Filter * -Properties homeDrive, homeDirectory |
    Select-Object SamAccountName, homeDrive, homeDirectory |
    Export-Csv -Path "$ReportFolder\HomeDir.csv" -NoTypeInformation

#Report of Dist Groups & Mail-Enabled Security Groups
Get-ADGroup -Filter * -Properties mail, groupCategory, groupScope |
    Where-Object { $_.mail -ne $null -and $_.mail -ne "" } |
    Select-Object Name, SamAccountName, mail, groupCategory, groupScope |
    Export-Csv -Path "$ReportFolder\EmailGroups.csv" -NoTypeInformation

#Report of above groups + members
$mailGroups = Get-ADGroup -Filter * -Properties mail, groupCategory, groupScope |
    Where-Object { $_.mail -ne $null -and $_.mail -ne "" }

$results3 = foreach ($group in $mailGroups) {

    $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction SilentlyContinue

    if ($members.Count -eq 0) {
        # Output a row even if the group has no members
        [PSCustomObject]@{
            GroupName      = $group.Name
            GroupSAM       = $group.SamAccountName
            Mail           = $group.mail
            GroupCategory  = $group.groupCategory
            GroupScope     = $group.groupScope
            MemberName     = ""
            MemberSAM      = ""
            MemberType     = ""
        }
    }
    else {
        foreach ($m in $members) {
            [PSCustomObject]@{
                GroupName      = $group.Name
                GroupSAM       = $group.SamAccountName
                Mail           = $group.mail
                GroupCategory  = $group.groupCategory
                GroupScope     = $group.groupScope
                MemberName     = $m.Name
                MemberSAM      = $m.SamAccountName
                MemberType     = $m.objectClass
            }
        }
    }
}
$results3 | Export-Csv -Path "$ReportFolder\EmailGroupsMembers.csv" -NoTypeInformation

#Report of all users, email addresses, and proxy address
Get-ADUser -Filter * -Properties mail, proxyAddresses, displayName |
    Select-Object `
        SamAccountName,
        displayName,
        mail,
        @{Name="EmailAliases"; Expression = {
            ($_.proxyAddresses |
                Where-Object { $_ -like "smtp:*" } |
                ForEach-Object { $_.Substring(5) }) -join ";"
        }} |
    Export-Csv -Path  "$ReportFolder\Email-ProxyAliases.csv" -NoTypeInformation

Stop-Transcript
