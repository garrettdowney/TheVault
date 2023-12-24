
.SYNOPSIS
Loops through the recycle bin and output a csv string.
Uses PNP Powershell.
.EXAMPLE
-URL:'https://<tenant>.sharepoint.com/sites/<siteCollection>' -Stage:First -Path:.\FirstRecycleBin.csv 
-URL:'https://<tenant>.sharepoint.com/sites/<siteCollection>' -Stage:First -Path:.\FirstRecycleBin.csv -RowLimit:200000
#>

#[CmdletBinding(SupportsShouldProcess)]
param(

    # The url to the site containing the Site Requests list
    $Url='https://qmpower.sharepoint.com/sites/engineering'
    $Stage='First'
    $Path=.\FirstRecycleBin.csv

   
)


Connect-PnPOnline -Url:$Url -UseWebLogin

Write-Host "Getting recycle bin items..."
$RecycleStage;
if ($Stage -eq "First") {
    $RecycleStage = Get-PnPRecycleBinItem -FirstStage -RowLimit 150000
}
else {
    $RecycleStage = Get-PnPRecycleBinItem -SecondStage -RowLimit 150000
}
$Output = @()


$RecycleStage | ForEach-Object {
    $Item = $PSItem
    $Obj = "" | Select-Object Title, AuthorEmail, AuthorName, DeletedBy, DeletedByEmail, DeletedDate, Directory, ID, ItemState, ItemType, LeafName, Size
    $Obj.Title = $Item.Title
    $Obj.AuthorEmail = $Item.AuthorEmail
    $Obj.AuthorName = $Item.AuthorName
    $Obj.DeletedBy = $Item.DeletedByName
    $Obj.DeletedByEmail = $Item.DeletedByEmail
    $Obj.DeletedDate = $Item.DeletedDate
    $Obj.Directory = $Item.DirName
    $Obj.ID = $Item.ID
    $Obj.ItemState = $Item.ItemState
    $Obj.ItemType = $Item.ItemType
    $Obj.LeafName = $Item.LeafName
    $Obj.Size = $Item.Size

    $output += $Obj
}

$Output | Export-csv $Path -NoTypeInformation

Write-Host "Done"
