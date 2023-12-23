Connect-AzureAD

# To set the password of one user to never expire, run the following cmdlet by using the UPN or the user ID of the user:
Set-AzureADUser -ObjectId <user ID> -PasswordPolicies DisablePasswordExpiration

# To set the passwords of all the users in an organization to never expire, run the following cmdlet:
# Get-AzureADUser -All $true | Set-AzureADUser -PasswordPolicies DisablePasswordExpiration