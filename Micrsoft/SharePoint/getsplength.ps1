#Parameters
$SiteURL = "https://yourdomain.sharepoint.com/"
$MaxUrlLength = 218
$CSVPath = "/Documents/LongURLInventory.csv"
$global:LongURLInventory = @()
$Pagesize = 2000 
  
#Function to scan and collect long files
Function Get-PnPLongURLInventory
{
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Web)
  
    Write-host "Scanning Files with Long URL in Site '$($Web.URL)'" -f Yellow
    If($Web.ServerRelativeUrl -eq "/")
    {
        $TenantURL= $Web.Url
    }
    Else
    {
        $TenantURL= $Web.Url.Replace($Web.ServerRelativeUrl,'')
    }
     
    #Get All Large Lists from the Web - Exclude Hidden and certain lists
    $ExcludedLists = @("Form Templates", "Preservation Hold Library","Site Assets", "Pages", "Site Pages", "Images",
                            "Site Collection Documents", "Site Collection Images","Style Library") 
                              
    #Get All Document Libraries from the Web
    $Lists= Get-PnPProperty -ClientObject $Web -Property Lists
    $Lists | Where-Object {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $false -and $_.Title -notin $ExcludedLists -and $_.ItemCount -gt 0} -PipelineVariable List | ForEach-Object {
        #Get Items from List   
        $global:counter = 0;
        $ListItems = Get-PnPListItem -List $_ -PageSize $Pagesize -Fields Author, Created, File_x0020_Type -ScriptBlock { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($_.ItemCount) * 100) -Activity "Getting List Items of '$($_.Title)'" -Status "Processing Items $global:Counter to $($_.ItemCount)";}
        $LongListItems = $ListItems | Where { ([uri]::EscapeUriString($_.FieldValues.FileRef).Length + $TenantURL.Length ) -gt $MaxUrlLength }
        Write-Progress -Activity "Completed Retrieving Items from List $($List.Title)" -Completed
                 
        If($LongListItems.count -gt 0)
        {
            #Get Root folder of the List
            $Folder = Get-PnPProperty -ClientObject $_ -Property RootFolder
            Write-host "`tFound '$($LongListItems.count)' Items with Long URLs at '$($Folder.ServerRelativeURL)'" -f Green
 
            #Iterate through each long url item and collect data           
            ForEach($ListItem in $LongListItems)
            {
                #Calculate Encoded Full URL of the File
                $AbsoluteURL =  "$TenantURL$($ListItem.FieldValues.FileRef)"
                $EncodedURL = [uri]::EscapeUriString($AbsoluteURL)
  
                    #Collect document data
                    $global:LongURLInventory += New-Object PSObject -Property ([ordered]@{
                        SiteName  = $Web.Title
                        SiteURL  = $Web.URL
                        LibraryName = $List.Title
                        LibraryURL = $Folder.ServerRelativeURL
                        ItemName = $ListItem.FieldValues.FileLeafRef
                        Type = $ListItem.FileSystemObjectType
                        FileType = $ListItem.FieldValues.File_x0020_Type
                        AbsoluteURL = $AbsoluteURL
                        EncodedURL = $EncodedURL
                        UrlLength = $EncodedURL.Length                      
                        CreatedBy = $ListItem.FieldValues.Author.LookupValue
                        CreatedByEmail  = $ListItem.FieldValues.Author.Email
                        CreatedAt = $ListItem.FieldValues.Created
                        ModifiedBy = $ListItem.FieldValues.Editor.LookupValue
                        ModifiedByEmail = $ListItem.FieldValues.Editor.Email
                        ModifiedAt = $ListItem.FieldValues.Modified                        
                    })
                }
            }
        }
}
 
#Connect to Site collection
Connect-PnPOnline -Url $SiteURL -Interactive
   
#Call the Function for all Webs
Get-PnPSubWeb -Recurse -IncludeRootWeb | ForEach-Object { Get-PnPLongURLInventory $_ }
  
#Export Documents Inventory to CSV
$Global:LongURLInventory | Export-Csv $CSVPath -NoTypeInformation
Write-host "Report has been Exported to '$CSVPath'"  -f Magenta

#Read more: https://www.sharepointdiary.com/2020/04/sharepoint-online-find-all-files-exceeding-maximum-url-length-using-powershell.html#ixzz7YpTKFrAR
