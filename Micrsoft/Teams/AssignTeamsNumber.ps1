Set-executionpolicy bypass
Install-Module -Name MicrosoftTeams
Connect-MicrosoftTeams
Set-CsPhoneNumberAssignment -Identity <UserID from Azure AD>   -PhoneNumber <Number to be assigned>  -PhoneNumberType CallingPlan