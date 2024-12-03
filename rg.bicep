targetScope = 'subscription'

@description('The location for the resource groups.')
param location string = 'westus2'

@description('The name of the resource group for ACR.')
param acrResourceGroupName string = 'my_acr_rg'

@description('The name of the resource group for AKS.')
param aksResourceGroupName string = 'my_aks_rg'

@description('The name of the resource group for VNet.')
param vnetResourceGroupName string = 'my_vnet_rg'

@description('The name of the resource group for Key Vault.')
param kvResourceGroupName string = 'my_kv_rg'

resource acrResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: acrResourceGroupName
  location: location
  properties: {}
}

resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: aksResourceGroupName
  location: location
  properties: {}
}

resource vnetResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: vnetResourceGroupName
  location: location
  properties: {}
}

resource kvResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: kvResourceGroupName
  location: location
  properties: {}
}

output acrResourceGroupName string = acrResourceGroupName
output aksResourceGroupName string = aksResourceGroupName
output vnetResourceGroupName string = vnetResourceGroupName
output kvResourceGroupName string = kvResourceGroupName
