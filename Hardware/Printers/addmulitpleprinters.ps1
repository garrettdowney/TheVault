$printers = import-csv -Path C:\Filepath\printers.csv

foreach ($printer in $printers) {
    Add-PrinterPort -Name $printer.IPAddress -PrinterHostAddress $printer.IPAddress
    Add-Printer -Name $printer.Printername -DriverName $printer.PrinterDriver -PortName $printer.IPAddress
}