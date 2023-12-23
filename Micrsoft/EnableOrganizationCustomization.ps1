Set-executionPolicy remotesigned
install-module -name ExchangeOnlineManagement
import-module -name ExchangeOnlineManagement
Connect-exchangeonline
Enable-OrganizationCustomization