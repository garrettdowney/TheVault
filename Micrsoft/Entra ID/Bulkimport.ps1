#Connect to Exchange online
Connect-ExchangeOnline

#Connect to MSOL Service
Connect-MsolService

#Code to import variables and update info
Import-Csv C:\temp\users.csv | foreach{Set-MsolUser -UserPrincipalName $_.UserPrincipalName -StreetAddress $_.StreetAddress -Office $_.Office -Fax $_.Fax -Title $_.title -Department $_.Department -City $_.City -PostalCode $_.PostalCode -PhoneNumber $_.Phone -State $_.State}