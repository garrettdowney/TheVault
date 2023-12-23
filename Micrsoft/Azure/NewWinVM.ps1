set-executionpolicy unrestricted -Force

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

net user /add Cadence CAD3NC3@2022

net localgroup administrators Cadence /add
net localgroup "Remote Desktop Users" Cadence /add

$Name = Read-Host -Prompt 'Input Name of VM'

Rename-computer -NewName $Name | Restart-computer