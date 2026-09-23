# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE :
# Export all print queues and their associated printer IP addresses
# Run on the Print Server

#LOGGING
$SCRIPTNAME ="PrinterQueueExport"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS


$Report = foreach ($Printer in Get-Printer) {

    $Port = Get-PrinterPort -Name $Printer.PortName -ErrorAction SilentlyContinue

    [PSCustomObject]@{
         PrinterName = $Printer.Name
         DriverName = $Printer.DriverName
         ShareName = $Printer.ShareName
         PortName = $Printer.PortName
         IPAddress = $Port.PrinterHostAddress
         Location = $Printer.Location
         Comment = $Printer.Comment
         Shared = $Printer.Shared
         Published = $Printer.Published
    }
}


$Report | Sort-Object PrinterName | Export-Csv "C:\Temp\PrintQueues.csv" -NoTypeInformation

Write-Host "Export complete: C:\Temp\PrintQueues.csv"

Stop-Transcript