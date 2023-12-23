# 1 = Intranet
# 2 = Trusted Sites
# 3 = Internet Zone
# 4 = Restricted Sites

if (-not (Test-Path -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\northpointkc.sharepoint.com'))

{

New-Item -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\northpointkc.sharepoint.com'

Set-ItemProperty -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\northpointkc.sharepoint.com' -Name https -Value 2 -Type DWord

}