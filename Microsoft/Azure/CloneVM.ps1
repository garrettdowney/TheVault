#Existing virtual network where new virtual machine will be created  
$virtualNetworkName = '<Virtual Network Name>'  
  
#Resource group of the VM to be clonned from   
$resourceGroupName = '<Resource Group Name>'  
  
#Region where managed disk will be created  
$location = '<Geo Location>'  
  
#Names of source and target (new) VMs  
$sourceVirtualMachineName = '<Source VM Name>'  
$targetVirtualMachineName = '<Target VM Name>'  
  
#Name of snapshot which will be created from the Managed Disk  
$snapshotName = $sourceVirtualMachineName + '_OsDisk-snapshot'  
  
#Name of the new Managed Disk  
$diskName = $targetVirtualMachineName + '_OsDisk'  
  
#Size of new Managed Disk in GB  
$diskSize = 128  
  
#Storage type for the new Managed Disk (Standard_LRS / Premium_LRS / StandardSSD_LRS)  
$storageType = '<Storage Type>'  
  
#Size of the Virtual Machine (https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes)  
$targetVirtualMachineSize = '<Target VM Size>'  
  
#Set the subscription for the current session where the commands wil execute  
Select-AzureRmSubscription -SubscriptionId '<Subscription Id>'  
  
#Get the existing VM from which to clone from  
$sourceVirtualMachine = Get-AzVM -ResourceGroupName $resourceGroupName -Name $sourceVirtualMachineName  
  
#Create new VM Disk Snapshot  
$snapshot = New-AzSnapshotConfig -SourceUri $sourceVirtualMachine.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy  
$snapshot = New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName   
  
#Create a new Managed Disk from the Snapshot  
$disk = New-AzureRmDiskConfig -AccountType $storageType -DiskSizeGB $diskSize -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id  
$disk = New-AzureRmDisk -Disk $disk -ResourceGroupName $resourceGroupName -DiskName $diskName  
  
#Initialize virtual machine configuration  
$targetVirtualMachine = New-AzureRmVMConfig -VMName $targetVirtualMachineName -VMSize $targetVirtualMachineSize  
  
#Attach Managed Disk to target virtual machine. OS type depends OS present in the disk (Windows/Linux)  
$targetVirtualMachine = Set-AzureRmVMOSDisk -VM $targetVirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Windows  
  
#Create a public IP for the VM  
$publicIp = New-AzureRmPublicIpAddress -Name ($targetVirtualMachineName.ToLower() + '_ip') -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Dynamic  
  
#Get Virtual Network information  
$vnet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName  
  
# Create Network Interface for the VM  
$nic = New-AzureRmNetworkInterface -Name ($targetVirtualMachineName.ToLower() + '_nic') -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id  
$targetVirtualMachine = Add-AzureRmVMNetworkInterface -VM $targetVirtualMachine -Id $nic.Id  
  
#Create the virtual machine with Managed Disk attached  
New-AzureRmVM -VM $targetVirtualMachine -ResourceGroupName $resourceGroupName -Location $location  
  
#Remove the snapshot  
Remove-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName -Force  