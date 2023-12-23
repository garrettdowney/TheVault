#Parameters
$UserID = Read-Host -Prompt "Input users email address"
 

#Connect to Azure AD
Connect-AzureAD
 
#Get User's Group Memberships
Get-AzureADUserOwnedObject -ObjectId $UserID | Where-object { $_.ObjectType -eq "Group" }
 