# Check the uptime
$uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Convert the uptime to days
$uptimeDays = [math]::Round(((Get-Date) - $uptime).TotalDays)

# Check if the uptime is 7 days or more
if ($uptimeDays -ge 7) {
  # Reboot the computer
  Restart-Computer
}
