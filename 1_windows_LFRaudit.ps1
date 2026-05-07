﻿# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : Audits the regkeys for folder redirection and saves a device report to a network share.
#Plan to deploy via RMM tool in bulk to domain joined workstations.

#LOGGING
$SCRIPTNAME ="LFRaudit"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS

$share = "\\server\share\folder" #Public Share that each machine can write to. 


#
$computer = $env:COMPUTERNAME

$results = @()
$flagVit = $false

$profiles = Get-CimInstance Win32_UserProfile |
    Where-Object {
        $_.LocalPath -like 'C:\Users\*' -and
        $_.Special -eq $false
    }

foreach ($p in $profiles) {
    $sid = $p.SID
    $userPath = $p.LocalPath
    $ntUser = Join-Path $userPath 'NTUSER.DAT'
    $hiveLoaded = $false
    $hkuPath = "Registry::HKEY_USERS\$sid"

    if (-not (Test-Path $hkuPath)) {
        if (Test-Path $ntUser) {
            reg load "HKU\$sid" $ntUser | Out-Null
            $hiveLoaded = $true
        }
    }

    $reg = "$hkuPath\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

    if (Test-Path $reg) {
        $f = Get-ItemProperty $reg -ErrorAction SilentlyContinue

        $folders = @{
            Desktop   = $f.Desktop
            Documents = $f.Personal
            Pictures  = $f.'My Pictures'
            Music     = $f.'My Music'
        }

        foreach ($k in $folders.Keys) {
            if (-not $folders[$k]) { continue }

            $expanded = [Environment]::ExpandEnvironmentVariables($folders[$k])

            if ($expanded -notlike "$userPath*") {
                $results += "$userPath | $k | $expanded"
            }
        }
    }

    if ($hiveLoaded) {
        reg unload "HKU\$sid" | Out-Null
    }

}


$outputFile = Join-Path $share "$computer.txt"


if ($results.Count -eq 0) {
    "NO REDIRECTION" | Out-File $outputFile -Encoding UTF8
} else {
    $results | Out-File $outputFile -Encoding UTF8
}

Stop-Transcript