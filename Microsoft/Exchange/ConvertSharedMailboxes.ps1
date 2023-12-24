# Connect to Exchange Online
Connect-ExchangeOnline

# Specify the list of user accounts to convert to shared mailboxes
$Accounts = @("user1@example.com", "user2@example.com", "user3@example.com")

# Convert each account to a shared mailbox
foreach ($Account in $Accounts) {
    Set-Mailbox -Identity $Account -Type Shared
}

# Disconnect from Exchange Online
Remove-PSSession $Session