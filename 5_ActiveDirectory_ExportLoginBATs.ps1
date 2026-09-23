# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE :
# Export all .bat files into a single .txt file for review

#LOGGING
$SCRIPTNAME ="LoginScriptsExport"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS
$SourcePath = "\\DOMAIN\SYSVOL\DOMAIN\scripts"
$OutputFile = "C:\Temp\All_LoginScripts.txt"

if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
}

Get-ChildItem -Path $SourcePath -Filter *.bat -Recurse |
    Sort-Object FullName |
    ForEach-Object {

        Add-Content -Path $OutputFile -Value ("=" * 80)
        Add-Content -Path $OutputFile -Value ("FILE: $($_.FullName)")
        Add-Content -Path $OutputFile -Value ("=" * 80)
        Add-Content -Path $OutputFile -Value ""

        Get-Content $_.FullName |
            Add-Content -Path $OutputFile

        Add-Content -Path $OutputFile -Value "`r`n"
    }

Write-Host "Export complete: $OutputFile"

Stop-Transcript