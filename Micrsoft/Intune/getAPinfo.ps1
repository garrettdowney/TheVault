Install-Script get-windowsautopilotinfo -confirm:$false -Force

$text = $env:COMPUTERNAME
$user = $env:USERPROFILE

get-windowsautopilotinfo.ps1 | Export-Csv $user\downloads\$text.csv