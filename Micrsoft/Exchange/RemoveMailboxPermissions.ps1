# Connect to Exchange Online
Connect-ExchangeOnline

# Specify the mailbox email address
$Mailbox = "aschaffer@northpointlogistics.com"

# Get all SendAs permissions for the mailbox
$SendAsPermissions = Get-RecipientPermission -Identity $Mailbox -AccessRights SendAs

# Get all FullAccess permissions for the mailbox
$FullAccessPermissions = Get-MailboxPermission -Identity $Mailbox | Where-Object {$_.AccessRights -eq "FullAccess"}

# Remove all SendAs permissions
foreach ($Permission in $SendAsPermissions) {
    Remove-RecipientPermission -Identity $Mailbox -AccessRights SendAs -Trustee $Permission.Trustee
}

# Remove all FullAccess permissions
foreach ($Permission in $FullAccessPermissions) {
    Remove-MailboxPermission -Identity $Mailbox -User $Permission.User -AccessRights $Permission.AccessRights
}

# Disconnect from Exchange Online
Remove-PSSession $Session