???
<#

Copyright (c) 2021 Microsoft
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script
Description: Creates registry entries to configure OneDrive Known Folder Move, removes built-in apps including Microsoft Store
Parameters: None
Returns: True on success, False on error
Logs: Logs steps to public documents folder
For use with Microsoft Intune PowerShell script deployment
#>


<#
Writes log file to public documents folder
#>

Function writeLogFile
{

param
    (
    [Parameter(Mandatory=$true)]
    [ValidateLength(10,500)]
    [string] $logMsg,
    [Parameter(Mandatory=$false)]
    [string] $msgtype = 'Info'

    )

# use public docs local path
$pubdocpath = $env:PUBLIC + "\Documents\KFMAppScript"

# create folder if it does not exist
# don't fail if logging is not possible on device

if ( ! (Test-Path -path "$pubdocpath")) {
    Write-Host  -ForegroundColor "yellow" "Creating log path"
    try{
        New-Item -ItemType directory -Path $pubdocpath
    } catch [Exception]{
      write-host  -ForegroundColor "red" $_.Exception.Message; 
      write-host  -ForegroundColor "red" "Unable to create log file folder: $pubdocpath"
      return
    }

}
 

 $logfilename = "$pubdocpath\KFMAppScriptlog.txt"
  
 $dt = Get-Date -UFormat "%m/%d/%Y %T" 

 $logoutmessage = $dt.ToString() + ' ' + $msgtype + ' ' + $logMsg

 #Write-host "log: " + $logoutmessage
  if($msgtype -eq 'Startup'){
    Add-Content -Path $logfilename -Value "==========================  Session Start =========================="
     Write-Host  -ForegroundColor "yellow" "LOG: ==========================  Session Start =========================="
  }
  
 Add-Content -Path $logfilename -Value $logoutmessage
 if ($msgtype -eq "Error") {
     Write-Host  -ForegroundColor "red" "LOG: " $logoutmessage
 }
 else {
    Write-Host  -ForegroundColor "yellow" "LOG: " $logoutmessage
 }

   if($msgtype -eq 'Shutdown'){
    Add-Content -Path $logfilename -Value "==========================  Session End =========================="
       Write-Host  -ForegroundColor "yellow" "LOG: ==========================  Session End =========================="
  }
  
}

<#
  // Function getTenantId
  // Description:  Reads enrollment data from registry to get tenant Id
  // This is needed to enable OneDrive Known Folder Move
  // Arguments:  None
  // Return type: Int
  // Returns: tenant GUID or "NotFound"
#>

function getTenantId {

   ## check path existence first, extra check

   if ( !( Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\CloudDomainJoin\TenantInfo)) {
     return("NotFound")
   } 

   ## Exists - continue
    try{
            Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\CloudDomainJoin\TenantInfo | ForEach-Object {
              # should ever only be one member
              return $_.Name.Substring($_.Name.Length - 36,36)
            }
        }
     catch [Exception] {
       writeLogFile -msgtype "Error" -logMsg  "Unable to find enrollment and associated tenant in registry at HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\CloudDomainJoin\TenantInfo"
       writeLogFile -msgtype "Error" -logMsg $_.Exception.GetType().FullName;
       writeLogFile -msgtype "Error" -logMsg $_.Exception.Message;
       writeLogFile -logMsg "Unable to configure OneDrive Known Folder Move"
       return("NotFound")
     }

}

## Sequence starts here
## All functions above this line

writeLogFile -msgtype 'Startup' -logMsg "Starting Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script"

## Ensure exceptions are thrown - Tenant Id is required
$ErrorActionPreference = "Stop"

## Initial value to handle the case when not set otherwise
$TID ="NotFound"

writeLogFile -msgtype 'Startup' -logMsg "Starting script..."

# Ensure passing error action into function
$TID = getTenantId -ErrorAction Stop

if ($TID -eq "NotFound"){
  writeLogFile -msgtype "Error" -logMsg  "Unable to find enrollment and associated tenant in registry"
  writeLogFile -logMsg "Unable to configure OneDrive Known Folder Move"
  writeLogFile -msgtype 'Shutdown' -logMsg "Completing Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script"
  return($false)
}

try{
    writeLogFile -logMsg "Creating registry path: HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
    $registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'##Path to HKLM keys
    If(!(Test-Path $registryPath))
    {New-Item -Path $registryPath -Force}
    #Enable silent account configuration
    writeLogFile -logMsg "Creating registry entry: SilentAccountConfig"
    New-ItemProperty -Path $registryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null
    #Enable files on demand
    writeLogFile -logMsg "Creating registry entry: FilesOnDemandEnabled"
    New-ItemProperty -Path $registryPath -Name 'FilesOnDemandEnabled' -Value '1' -PropertyType DWORD -Force | Out-Null
    #Prevent users from moving their Windows known folders to OneDrive
    writeLogFile -logMsg "Creating registry entry: KFMBlockOptIn"
    New-ItemProperty -Path $registryPath -Name 'KFMBlockOptIn' -Value '1' -PropertyType DWORD -Force | Out-Null
    #Silently move Windows known folders to OneDrive
    writeLogFile -logMsg "Creating registry entry: KFMSilentOptIn"
    New-ItemProperty -Path $registryPath -Name 'KFMSilentOptIn' -Value $TID -PropertyType String -Force | Out-Null
    #Setting this value to 1 displays a notification after successful redirection
    writeLogFile -logMsg "Creating registry entry: KFMSilentOptInWithNotification"
    New-ItemProperty -Path $registryPath -Name 'KFMSilentOptInWithNotification' -Value '0' -PropertyType DWORD -Force | Out-Null
    #Prevent users from redirecting their Windows known folders to their PC
    writeLogFile -logMsg "Creating registry entry: KFMBlockOptOut"
    New-ItemProperty -Path $registryPath -Name 'KFMBlockOptOut' -Value '1' -PropertyType DWORD -Force | Out-Null
}
 catch [Exception]  {
  write-Host  ' '
  write-host  -ForegroundColor "red" $_.Exception.Message; 
  writeLogFile -msgtype "Error" -logMsg  "Failed to create registry keys"
  writeLogFile -msgtype "Error" -logMsg $_.Exception.GetType().FullName;
  writeLogFile -msgtype "Error" -logMsg $_.Exception.Message;
  writeLogFile -logMsg "Unable to configure OneDrive Known Folder Move"
  writeLogFile -logMsg "Completing Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script (Failed)"
  return $false
 } 
  
# If we got here assume success
writeLogFile -logMsg "Successfully enabled OneDrive Known Folder Move for tenant ID $TID" 

try{
writeLogFile -logMsg "Removing provisioned Appx packages" 	
Get-AppXProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online
##  To remove only certain apps, use where clause for simple criteria logic or iterate through objects
writeLogFile -logMsg "Removed provisioned Appx packages" 
}
 catch [Exception]  {
  write-Host  ' '
  write-host  -ForegroundColor "red" $_.Exception.Message; 
  writeLogFile -msgtype "Error" -logMsg  "Failed to remove provisioned Appx packages"
  writeLogFile -msgtype "Error" -logMsg $_.Exception.GetType().FullName;
  writeLogFile -msgtype "Error" -logMsg $_.Exception.Message;
  writeLogFile -logMsg "Unable to remove provisioned Appx packages"
  writeLogFile -logMsg "Completed Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script (Failed)"
  return $false
 } 
writeLogFile -msgtype 'Shutdown' -logMsg "Completed Windows 10 in cloud configuration OneDrive Known Folder Move and built-in app removal script (Success)"


return $true
# SIG # Begin signature block
# MIIjlgYJKoZIhvcNAQcCoIIjhzCCI4MCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA4zkVWI7fyFRa1
# X11+6E4c7YStUvTiRvYwZtXGLOxXjaCCDYUwggYDMIID66ADAgECAhMzAAABiK9S
# 1rmSbej5AAAAAAGIMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ4WhcNMjEwMzAzMTgzOTQ4WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCSCNryE+Cewy2m4t/a74wZ7C9YTwv1PyC4BvM/kSWPNs8n0RTe+FvYfU+E9uf0
# t7nYlAzHjK+plif2BhD+NgdhIUQ8sVwWO39tjvQRHjP2//vSvIfmmkRoML1Ihnjs
# 9kQiZQzYRDYYRp9xSQYmRwQjk5hl8/U7RgOiQDitVHaU7BT1MI92lfZRuIIDDYBd
# vXtbclYJMVOwqZtv0O9zQCret6R+fRSGaDNfEEpcILL+D7RV3M4uaJE4Ta6KAOdv
# V+MVaJp1YXFTZPKtpjHO6d9pHQPZiG7NdC6QbnRGmsa48uNQrb6AfmLKDI1Lp31W
# MogTaX5tZf+CZT9PSuvjOCLNAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUj9RJL9zNrPcL10RZdMQIXZN7MG8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQ1ODM4NjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# ACnXo8hjp7FeT+H6iQlV3CcGnkSbFvIpKYafgzYCFo3UHY1VHYJVb5jHEO8oG26Q
# qBELmak6MTI+ra3WKMTGhE1sEIlowTcp4IAs8a5wpCh6Vf4Z/bAtIppP3p3gXk2X
# 8UXTc+WxjQYsDkFiSzo/OBa5hkdW1g4EpO43l9mjToBdqEPtIXsZ7Hi1/6y4gK0P
# mMiwG8LMpSn0n/oSHGjrUNBgHJPxgs63Slf58QGBznuXiRaXmfTUDdrvhRocdxIM
# i8nXQwWACMiQzJSRzBP5S2wUq7nMAqjaTbeXhJqD2SFVHdUYlKruvtPSwbnqSRWT
# GI8s4FEXt+TL3w5JnwVZmZkUFoioQDMMjFyaKurdJ6pnzbr1h6QW0R97fWc8xEIz
# LIOiU2rjwWAtlQqFO8KNiykjYGyEf5LyAJKAO+rJd9fsYR+VBauIEQoYmjnUbTXM
# SY2Lf5KMluWlDOGVh8q6XjmBccpaT+8tCfxpaVYPi1ncnwTwaPQvVq8RjWDRB7Pa
# 8ruHgj2HJFi69+hcq7mWx5nTUtzzFa7RSZfE5a1a5AuBmGNRr7f8cNfa01+tiWjV
# Kk1a+gJUBSP0sIxecFbVSXTZ7bqeal45XSDIisZBkWb+83TbXdTGMDSUFKTAdtC+
# r35GfsN8QVy59Hb5ZYzAXczhgRmk7NyE6jD0Ym5TKiW5MIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCFWcwghVjAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAGIr1LWuZJt6PkAAAAA
# AYgwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA0e
# IkElK+6m2aqCMGO0ANPg8JyUy+vyFgE1AI73nfBjMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAj1Ebk2Z+wAF6uDmNV+754kzRtst3mWZhV7Qn
# Ldb5OKPgNsYlgSeEvs9k0h4Q2eMVulv/w7z19ILOgo+PtW9KPsb49+feo4SPMD38
# I7EejtEUCy+1TaCv4TrA4cZT4l4c9v3xaiAJFX3vDUJz1hTR/PgXWklPvhQaLOKr
# oMqlT+9qalIIbj90ZsMDzXB2HVIUfVhwYi6EUOQz030uGmUZ1wMbFYK2nN6ppPHK
# j7+Idm48F9z7pV/NNbzya0gxT6PQH8guWTNm2/qBqhrKKL5gpCSx8tl4iByEEf1n
# fHccXbm30qCxPRJDWbZOSaCcuKKih42SFSEx7Bt1LVULTkAsvKGCEvEwghLtBgor
# BgEEAYI3AwMBMYIS3TCCEtkGCSqGSIb3DQEHAqCCEsowghLGAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFVBgsqhkiG9w0BCRABBKCCAUQEggFAMIIBPAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCD4XG4lZUnoHaHfObsewp96EsyAC2Afo2Qs
# Z+Hp0NtdewIGYBBftC6DGBMyMDIxMDIwMjIyNDMxOS4wNDlaMASAAgH0oIHUpIHR
# MIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQL
# EyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046QzRCRC1FMzdGLTVGRkMxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2Wggg5EMIIE9TCCA92gAwIBAgITMwAAASM4sOSt2FqQ
# nQAAAAABIzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0xOTEyMTkwMTE0NTZaFw0yMTAzMTcwMTE0NTZaMIHOMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQg
# T3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046
# QzRCRC1FMzdGLTVGRkMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
# cnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCdvNDJsGSl3AEu
# 8dmbwOEzjgs8Put17PVCxlrXWQzd1ZfmhkBLDMBKyJIM0ItH0ztLDg/Td4TtR2k1
# h6EvNDf0G+qC0dlgmZL/1TOFhZ04Tr98gOc0rfr7ijcK4xBxQtI5TAwiamlO0rel
# iW5f5AD+bIDNKraRBEIcbVWn/CKFeZavL4DCTa99DuK6i2BIv2GVkGWMEBwIlTLp
# wmKSYnHJzTjUUXYNg908rttnhCcD0D+g5HhIqDMvXoTJga5IwA1ToEFfk+Joq/oQ
# CXiDcrKbOsIETuao7lefo73MzUGtVpu48bKgb9OBgpSKeTR7610JmfZqWXY9648R
# bmWyo3dxAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQUgdRsFIDTjRv5EcKwaN4ZFfgM
# nh4wHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljVGltU3RhUENBXzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNU
# aW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
# BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEAW+UBt6pX6Fuq9VeJU/pDvC1M
# xd9kt31H4J/0tUEAT8zkbP+ro49PcrR1jQ3znsMJEsmtX/EvXvgW515Jx+Zd0ep0
# tgZEUwDbU5l8bzC0wsr3mHvyUCH6LPmd4idG9ahw0pxI+kJnX9TMpqzwJOY8YcYY
# ol5cCC1I7x+esu6yx8StMJ7B9dhDvTJ5GkjVyTQpkpn4FBJAzc7udwt/ZelzUQD2
# rs9v1rJSFGXF9zQwjIL+YWYtp4XffR8cmiSbHJ9X/IWVwPvn9RzW6vG3ZIdzmIEZ
# za+0HZzvhrr7bt3chqmHUDDBj5wLeC+xMPcpI8tFKM+uP69Em0CEWLcuXjPTNzCC
# BnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
# dCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1
# NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/
# aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxh
# MFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhH
# hjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tk
# iVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox
# 8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJN
# AgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIox
# kPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0P
# BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9
# lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
# Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3Js
# MFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAG
# A1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAG
# CCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEA
# dABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXED
# PZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgr
# UYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c
# 8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFw
# nzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFt
# w5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk
# 7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9d
# dJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zG
# y9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3
# yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7c
# RDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wkn
# HNWzfjUeCLraNtvTX4/edIhJEqGCAtIwggI7AgEBMIH8oYHUpIHRMIHOMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3Nv
# ZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046QzRCRC1FMzdGLTVGRkMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVALoXZo3g4p4Xwu4MNSgQnjP7+1eBoIGD
# MIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEF
# BQACBQDjxBhMMCIYDzIwMjEwMjAyMjIyODI4WhgPMjAyMTAyMDMyMjI4MjhaMHcw
# PQYKKwYBBAGEWQoEATEvMC0wCgIFAOPEGEwCAQAwCgIBAAICJdgCAf8wBwIBAAIC
# EicwCgIFAOPFacwCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAK
# MAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQB8QvOh5Sbe
# SdiWFohAp5evV8edRLxepoYbbZRiyqlR80dP5Ufx1Z0zyWcJ5L0yWsQqQZOEDzs4
# mEBbAlNQ0sbmGs0jHArKB1n+Y5vpOPmHyexYcVnbDlozQbyVCtZ1JDhlrEQM6RDq
# vxVdVvcHnhSPfhZddqPc5LC7nsKuoaB4YTGCAw0wggMJAgEBMIGTMHwxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABIziw5K3YWpCdAAAAAAEjMA0GCWCG
# SAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZI
# hvcNAQkEMSIEIIwwivBcQIVVwRSvVGo38Qv1xz4JK7XN6UZb6BUThlHhMIH6Bgsq
# hkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgEZozgz/7RMzEDaOjrMSkAAy/KcCiZDOW
# J1yq6vsVgbMwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
# MwAAASM4sOSt2FqQnQAAAAABIzAiBCBkaFI1F8XEpCzrc1gXSyTP7mDsopt8oAE0
# ozi+WB75GzANBgkqhkiG9w0BAQsFAASCAQCBuyYeLqa8yrKUbXmMcGW3fMdPoz1+
# qHcSvJ36s5oRVxBxMndAWW5v2Qc5mHWh1b8L6sBIBVt0tt80C/M/KRIIq8dZVx29
# 6UwKmcBR+twbqwgTqAUUqljq0UlScR8w+Iz8XvKHFzHYVcpNtEcmF+P8Tb853ojl
# UfeGvp1nGRYB40tXmrN30+CugXnJRyb2B8F5BUeymJJ3XG8wWuJ474u51pRecr3E
# U3Cd9/8bNC+M097aOFe3riAgY8xR+SzcarkhnEj4U5R3LU5kSagsYMaDJmuhuNdi
# Sx3Q7j3iIqWxiTrFWHh7v7A/oSkimx6faC5X2pWk+0QoWNMdXUKqUjhq
# SIG # End signature block

