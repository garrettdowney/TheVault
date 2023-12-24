Connect-AzureAD

# To set the password of one user so that the password expires, run the following cmdlet by using the UPN or the user ID of the user:
Set-AzureADUser -ObjectId <user ID> -PasswordPolicies None

# To set the passwords of all users in the organization so that they expire, use the following cmdlet:
# Get-AzureADUser -All $true | Set-AzureADUser -PasswordPolicies None