#########User info######
$userToOffboard = Read-Host -Prompt 'Input users email address to offboard'
$manager = Read-Host -Prompt 'Users manager to forward emails to'
###

write-host "Logging into Azure AD." -ForegroundColor Green
Connect-AzureAD
write-host "Connecting to Exchange Online" -ForegroundColor Green
connect-exchangeonline


Write-Host "Disabling user account" -ForegroundColor Red
# Disable the user account
# Get the user account based on UPN for disabling account
$user = Get-AzureADUser -Filter "userPrincipalName eq '$userToOffboard'"
Set-AzureADUser -ObjectId $user.ObjectId -AccountEnabled $false

write-host "Setting mailbox to Shared Mailbox" -ForegroundColor Green
Set-Mailbox $userToOffboard -Type Shared
write-host "Hiding user from GAL" -ForegroundColor Green
Set-Mailbox $userToOffboard -HiddenFromAddressListsEnabled $true

Write-Host "Giving $manager full access to $usertoOffboard's mailbox" -ForegroundColor Yellow
Add-MailboxPermission -Identity $userToOffboard -User $manager -AccessRights FullAccess

Write-Host "Setting auto reply" -ForegroundColor DarkMagenta
Set-MailboxAutoReplyConfiguration -Identity $userToOffboard -AutoReplyState Enabled -InternalMessage "Thank you for your email. This person is no longer with DiPasquale Moore and unfortunately can no longer answer your email. Please direct your inquiries to $manager. They will be happy to assist you or please call the office at 816-888-7500. Please note that your email will not be forwarded automatically." -ExternalMessage "Thank you for your email. This person is no longer with DiPasquale Moore and unfortunately can no longer answer your email. Please direct your inquiries to $manager. They will be happy to assist you or please call the office at 816-888-7500. Please note that your email will not be forwarded automatically." -ExternalAudience All

write-host "Removing users from Azure AD Groups" -ForegroundColor Green
$MemberID = (Get-AzureADUser -ObjectId $userToOffboard).objectId
Get-AzureADUserMembership -ObjectId $MemberID -All $true | Where-Object { $_.ObjectType -eq "Group" -and $_.SecurityEnabled -eq $true -and $_.MailEnabled -eq $false } | ForEach-Object {
    write-host "    Removing using from $($_.displayname)" -ForegroundColor green
    Remove-AzureADGroupMember -ObjectId $_.ObjectID -MemberId $MemberID
}
write-host "Removing users from Unified Groups and Teams" -ForegroundColor Green
$OffboardingDN = (get-mailbox -Identity $userToOffboard -IncludeInactiveMailbox).DistinguishedName
Get-Recipient -Filter "Members -eq '$OffboardingDN'" -RecipientTypeDetails 'GroupMailbox' | foreach-object {
    write-host "    Removing using from $($_.name)" -ForegroundColor green
    Remove-UnifiedGroupLinks -Identity $_.ExternalDirectoryObjectId -Links $userToOffboard -LinkType Member -Confirm:$false }

write-host "Removing users from Distribution Groups" -ForegroundColor Green
Get-Recipient -Filter "Members -eq '$OffboardingDN'" | foreach-object {
    write-host "    Removing using from $($_.name)" -ForegroundColor green
    Remove-DistributionGroupMember -Identity $_.ExternalDirectoryObjectId -Member $OffboardingDN -BypassSecurityGroupManagerCheck -Confirm:$false }

write-host "Removing License from user." -ForegroundColor Green
$AssignedLicensesTable = Get-AzureADUser -ObjectId $userToOffboard | Get-AzureADUserLicenseDetail | Select-Object @{n = "License"; e = { $_.SkuPartNumber } }, skuid
if ($AssignedLicensesTable) {
    $body = @{
        addLicenses    = @()
        removeLicenses = @($AssignedLicensesTable.skuid)
    }
    Set-AzureADUserLicense -ObjectId $userToOffboard -AssignedLicenses $body
}

write-host "Removed licenses:"
$AssignedLicensesTable
Remove-PSSession $session
