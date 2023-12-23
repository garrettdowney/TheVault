#Connect to ExchangeOnlineManagement

Import-Module -Name ExchangeOnlineManagement

Connect-ExchangeOnline

#Report Each Mailbox a User has access to

$MX = 'User principle name'

$mailboxes = Get-Mailbox -ResultSize Unlimited

foreach($mailbox in $mailboxes){Get-MailboxPermission -Identity $mailbox.Identity -User $MX}