$printers = import-csv -Path C:\Windows\Temp\ScreenConnect\23.1.1.8423\Files\printers.csv

foreach ($printer in $printers) {
    Add-PrinterPort -Name $printer.IPAddress -PrinterHostAddress $printer.IPAddress
    Add-Printer -Name $printer.Printername -DriverName $printer.PrinterDriver -PortName $printer.IPAddress
}