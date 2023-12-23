$BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
        $KeyProtectorID=""
        foreach($keyProtector in $BLV.KeyProtector){
            if($keyProtector.KeyProtectorType -eq "RecoveryPassword"){
                $KeyProtectorID=$keyProtector.KeyProtectorId
                break;
            }
        }

       $result = BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KeyProtectorID
       if($result){
           return $true
       }
       if($Error){
           return $false
       }
       return $false
