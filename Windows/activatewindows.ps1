$service = get-wmiObject -query 'select * from SoftwareLicensingService'
if($key = $service.OA3xOriginalProductKey){
	Write-Host 'Activating using product Key:' $service.OA3xOriginalProductKey
	$service.InstallProductKey($key)
}else{

	Write-Host 'Key not found., using Volume license'
        $service.InstallProductKey('VOLUME LICENSE KEY')
}