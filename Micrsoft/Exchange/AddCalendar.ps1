# variables for user to share and user to see/edit
$usertogive = Read-Host -Prompt "Which user is needing to give access?"
$usertosee = Read-Host -Prompt "Which user needs access?"

#Script to run
Add-MailboxFolderPermission -Identity ${usertogive}:\calendar -User $usertosee -AccessRights Author

#CSV Version
#Import-Csv users.csv | foreach { add-MailboxFolderPermission -Identity "user1@domain.com:\calendar" -User $_.alias -AccessRights Owner }