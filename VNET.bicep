@description('Name of the Virtual Network.')
param virtualNetworkName string = 'amanoilov-vnet'

@description('Address space for the Virtual Network.')
param addressSpace array = [
  '10.5.0.0/16'
]

@description('Subnets configuration for the Virtual Network.')
param subnets array = [
  {
    name: 'amanoilov-aks-subnet'
    addressPrefix: '10.5.1.0/24'
  }
  {
    name: 'amanoilov-private-endpoint-subnet'
    addressPrefix: '10.5.2.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
        locations: [
          '*'
        ]
      }
    ]
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworkName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace
    }
  }
}

resource virtualNetworkName_subnets_name 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = [
  for item in subnets: {
    parent: virtualNetwork
    name: '${item.name}'
    properties: {
      addressPrefix: item.addressPrefix
      serviceEndpoints: item.?serviceEndpoints ?? json('[]')
    }
  }
]

@description('The resource ID of the Virtual Network.')
output vnetId string = virtualNetwork.id


@description('The resource IDs of the subnets as an object where keys are the subnet names.')
output subnetIds array = [
  for i in range(0, length(subnets)): {
    resourceId: virtualNetworkName_subnets_name[i].id
    subnetName: virtualNetworkName_subnets_name[i].name
  }
]

output subnetIds2 array = [
  for (subnet, i) in subnets: {
    resourceId: virtualNetworkName_subnets_name[i].id
    subnetName: virtualNetworkName_subnets_name[i].name
  }
]


