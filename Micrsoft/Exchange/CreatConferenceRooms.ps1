##Prerequisites -- Istall ExchangeOnlineManagment -- Install MSOline

Install-Module ExchangeOnlineManagement
Install-Module MSOnline

# Connect to -- ExchangeOnline and Connect MsolService

Connect-MsolService
Connect-ExchangeOnline

# Variables

$Name = Read-Host -Prompt 'Input Name of Conference Room'
$Alias = Read-Host -Prompt 'Input Alias of Conference Room'
$UPN = Read-Host -Prompt 'Input Email Address of the Conference Room'
$RoomList = Read-Host -Prompt 'Input name of Conference Room List'

New-Mailbox -Name $Name -Alias $Alias -Room -EnableRoomMailboxAccount $true -MicrosoftOnlineServicesID $UPN -RoomMailboxPassword (ConvertTo-SecureString -String 'Welcome1' -AsPlainText -Force)

Set-CalendarProcessing -Identity $Name -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse 'This is a Microsoft Teams meeting room!'

Get-Mailbox -RecipientTypeDetails RoomMailbox

Get-DistributionGroup -RecipientTypeDetails RoomList

# Uncomment line below if you need to create a new distribution group (Room list)
# New-DistributionGroup -Name "NP Fresh Conference Rooms" -PrimarySmtpAddress "NPFConfRooms@northpointkc.com" -RoomList

Add-DistributionGroupMember -Identity $RoomList -Member $Name