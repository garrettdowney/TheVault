# This will be output whenever you go to connect to the fileshare in Azure, just ask it to output a script.

$connectTestResult = Test-NetConnection -ComputerName yourfileshare -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"yourfileshare`" /user:`"localhost/user`" /pass:`"**************************************`""
    # Mount the drive
    New-PSDrive -Name D -PSProvider FileSystem -Root "\\vmfileshare" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}