# Connect to SharePoint Online
$username = "user@yourdomain.com"
$password = ConvertTo-SecureString "yourpassword" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($username, $password)
Connect-PnPOnline -Url "https://yourdomain.sharepoint.com/sites/yoursite" -Credentials $credentials

# Get the library where you want to create the folders
$library = Get-PnPList -Identity "Shared Documents"

# Define the folders you want to create
$folders = @("Folder 1", "Folder 2", "Folder 3")

# Loop through the folders and create them
foreach ($folder in $folders) {
    Add-PnPFolder -List $library -Folder $folder
    Write-Host "Folder $folder created"
}

# Disconnect from SharePoint Online
Disconnect-PnPOnline
