Connect-AzureAD

$Password = Invoke-WebRequest -Uri https://www.dinopass.com/password/strong -UseBasicParsing | Select-Object -ExpandProperty content | ConvertTo-SecureString -AsPlainText -Force
Set-AzureADUserPassword -objectid "user@domain.com" -Password $Password
[System.Net.NetworkCredential]::new("", $Password).Password