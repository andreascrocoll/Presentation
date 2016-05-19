Param(
  $subscriptionName,
  $vmName,
  $rgName,
  $storageAccName,
  $vmUser,
  $vmPass
)

$location = "North Europe"
$vmSize = "Standard_A0"

$ErrorActionPreference = "Stop"

#check if VM exists
$vmExists = $true
try
{
Test-WSMan -ComputerName $vmName
}
catch
{
    write-host "VM not created"
    $vmExists = $false
}

if($vmExists)
{
    exit
}
write-host "Create VM"

Disable-AzureDataCollection

Select-AzureRmProfile -Path c:\azureprofile

# Select subscription
Select-AzureRmSubscription -SubscriptionName $subscriptionName

#get Virtual network
$subnetIndex=0
$vnet=Get-AzureRMVirtualNetwork -Name $rgName -ResourceGroupName $rgName

#create Public Ip Address and Network Interface
$pip = New-AzureRmPublicIpAddress -Name $vmName -ResourceGroupName $rgName -Location $location -DomainNameLabel $vmName -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -Name $vmName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Get storage account
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageAccName

#create VM config
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# create credentials
$PWord = ConvertTo-SecureString –String $vmPass –AsPlainText -Force
$cred = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $vmUser, $PWord

$vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$pubName="MicrosoftWindowsServer"
$offerName="WindowsServer"
$skuName="2012-R2-Datacenter"
$vm=Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$diskName="OSDisk"
$osDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $diskName  + ".vhd"
$vm=Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm

Start-Sleep -s 120