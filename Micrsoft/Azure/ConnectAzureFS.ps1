$connectTestResult = Test-NetConnection -ComputerName arcgissmb.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"arcgissmb.file.core.windows.net`" /user:`"localhost\arcgissmb`" /pass:`"PPDS0DM9ZjHsP75qhB+ZZhqQRLKDoCOHPatPIy3AlspcXCiBee4b88Bh6OzUVc6dHuWY2DmYEB8mJMI9dDtZCA==`""
    # Mount the drive
    New-PSDrive -Name D -PSProvider FileSystem -Root "\\arcgissmb.file.core.windows.net\fileshare\GIS_Data\output" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}