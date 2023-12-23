Get-AzureADUser -ObjectId 6fe3c001-6178-4099-abc0-a010f72003fa | Select-Object UserprincipalName,@{
    N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}
}