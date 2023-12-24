# Install required modules (if you are local admin) (only needed first time).
Install-Module -Name DCToolbox -Force
Install-Module -Name AzureADPreview -Force
Install-Package msal.ps -AcceptLicense -Force

# Install required modules as curren user (if you're not local admin) (only needed first time).
Install-Module -Name DCToolbox -Scope CurrentUser -Force
Install-Module -Name AzureADPreview -Scope CurrentUser -Force
Install-Package msal.ps -AcceptLicense -Force


# If you want to, you can run Connect-AzureAD before running Enable-DCAzureADPIMRole, but you don't have to.

# Enable one of your Azure AD PIM roles.
Enable-DCAzureADPIMRole

# Enable multiple Azure AD PIM roles.
Enable-DCAzureADPIMRole -RolesToActivate 'Exchange Administrator', 'Security Reader'

# Fully automate Azure AD PIM role activation.
Enable-DCAzureADPIMRole -RolesToActivate 'Exchange Administrator', 'Security Reader' -UseMaxiumTimeAllowed -Reason 'Performing some Exchange security coniguration according to change #12345.'

<#
    Example output:

    VERBOSE: Connecting to Azure AD...

    *** Activate PIM Role ***

    [1] User Account Administrator
    [2] Application Administrator
    [3] Security Administrator
    [0] Exit

    Choice: 3
    Reason: Need to do some security work!
    Duration [1 hour(s)]: 1
    VERBOSE: Activating PIM role...
    VERBOSE: Security Administrator has been activated until 11/13/2020 11:41:01!
#>


# Learn more about Enable-DCAzureADPIMRole.
help Enable-DCAzureADPIMRole -Full

# Privileged Identity Management | My roles:
# https://portal.azure.com/#blade/Microsoft_Azure_PIMCommon/ActivationMenuBlade/aadmigratedroles

# Privileged Identity Management | Azure AD roles | Overview:
# https://portal.azure.com/#blade/Microsoft_Azure_PIMCommon/ResourceMenuBlade/aadoverview/resourceId//resourceType/tenant/provider/aadroles
