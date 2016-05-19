Param(
  $subscriptionName,
  $vmName,
  $rgName
)

$ErrorActionPreference = "Stop"

Disable-AzureDataCollection

Select-AzureRmProfile -Path c:\azureprofile

Select-AzureRmSubscription -SubscriptionName $subscriptionName

Remove-AzureRmVM -ResourceGroupName $rgName –Name $vmName -Force
Remove-AzureRmNetworkInterface -Name $vmName -ResourceGroupName $rgName -Force
Remove-AzureRmPublicIpAddress -Name $vmName -ResourceGroupName $rgName -Force
