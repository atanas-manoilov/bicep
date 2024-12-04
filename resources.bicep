targetScope = 'subscription'
param KeyVaultName string = 'amanoilov-pipeline02'
param keyVaultExists bool
param existingKeyVaultName string
param utcSuffix string

@description('The name of the resource group for the VNet.')
param vnetResourceGroupName string = 'my_vnet_rg'

@description('The name of the resource group for the ACR.')
param kvResourceGroupName string = 'my_kv_rg'

@description('The name of the resource group for the ACR.')
param acrResourceGroupName string = 'my_acr_rg'

@description('The name of the resource group for the AKS.')
param aksResourceGroupName string = 'my_aks_rg'

var additionalObjectIds = [
  'c0cd7fd7-bd4b-4ecc-a059-a03b3994761f'
  '019bb3b3-c281-4fc1-87f7-df6974d55f91'
  '019bb3b3-c281-4fc1-87f7-df6974d55f91'
]

module vnetDeployment './VNET.bicep' = {
  name: 'vnetDeployment'
  scope: resourceGroup(vnetResourceGroupName)
  params: {}
}

module acrDeployment 'ACR.bicep' = {
  name: 'acrDeployment'
  scope: resourceGroup(acrResourceGroupName)
  params: {}
}

module kvDeployment './KV.bicep' = {
  name: 'kvDeployment'
  scope: resourceGroup(kvResourceGroupName)
  params: {
    privateEndpointSubnetId: first(filter(vnetDeployment.outputs.subnetIds, s => s.subnetName == 'amanoilov-private-endpoint-subnet')).resourceId
    vnetId: vnetDeployment.outputs.vnetId
    KeyVaultName: KeyVaultName
    existingKeyVaultName: existingKeyVaultName
    keyVaultExists: keyVaultExists
    utcSuffix: utcSuffix
  }
}

module aksDeployment './AKS.bicep' = {
  name: 'aksDeployment'
  scope: resourceGroup(aksResourceGroupName)
  params: {
    vnetSubnetID: first(filter(vnetDeployment.outputs.subnetIds, s => s.subnetName == 'amanoilov-aks-subnet')).resourceId
  }
}

module ACR_role_Deployment 'ACR_role_assignment.bicep' = {
  name: 'ACR_role_Deployment'
  scope: resourceGroup(acrResourceGroupName)
  params: {
    acrResourceId: acrDeployment.outputs.acrVaultId
    principalId: aksDeployment.outputs.kubeletUAMIObjectId
  }
}

module KV_policy_assignment 'KV_access_policies.bicep' = {
  name: 'KV_policy_assignment'
  scope: resourceGroup(kvResourceGroupName)
  params: {
    keyVaultResourceId: kvDeployment.outputs.keyVaultResourceId
    customObjectIds: union(
      additionalObjectIds,
      array(aksDeployment.outputs.kubeletUAMIObjectId)
    )
  }
}

output aks_cluster_name string = aksDeployment.outputs.aksClusterName
output aks_resource_group string = aksDeployment.outputs.aksClusterResourceGroup
output kv_name string = kvDeployment.outputs.kvName
output acr_name string = acrDeployment.outputs.acrName
