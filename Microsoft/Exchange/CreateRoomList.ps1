##Prerequisites -- Install ExchangeOnlineManagment -- Install MSOline
Install-Module ExchangeOnlineManagement
Install-Module MSOnline

# Connect to -- ExchangeOnline and Connect MsolService
Connect-MsolService
Connect-ExchangeOnline

# Replace <RoomListName> with the name of the room list you want to create
$roomListName = "<RoomListName>"

# Replace <City> with the city attribute you want to assign to the resource accounts
$city = "<City>"

# Replace <ResourceAccount1>, <ResourceAccount2>, etc. with the primary SMTP addresses of the resource accounts you want to add to the room list
$resourceAccounts = @("<ResourceAccount1>", "<ResourceAccount2>", "<ResourceAccount3>")

# Create the room list
New-DistributionGroup -Name $roomListName -RoomList

# Loop through the resource accounts and add them to the room list
foreach ($resourceAccount in $resourceAccounts) {
    Add-DistributionGroupMember -Identity $roomListName -Member $resourceAccount

    # Set the city attribute for the resource account
    Set-User -Identity $resourceAccount -City $city
}