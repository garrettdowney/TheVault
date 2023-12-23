set-executionpolicy unrestricted -Force

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

net user /add User Password

net localgroup administrators User /add
net localgroup "Remote Desktop Users" User /add

$Name = Read-Host -Prompt 'Input Name of VM'

Rename-computer -NewName $Name | Restart-computer