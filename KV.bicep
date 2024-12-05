param privateEndpointSubnetId string
param vnetId string
param KeyVaultName string
param keyVaultExists bool
param existingKeyVaultName string
param utcSuffix string


param allowedIps array = [
  {
    value: '89.102.176.88'
  }
]

@description('Location')
param location string = resourceGroup().location

@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'

param tenantId string = 'f985b02a-13bf-4b1e-88e7-d4ce214ad1b1'
param dnsLinkName string = 'kv-dns-link'
param environment string = 'production'

var targetKeyVaultName = keyVaultExists ? existingKeyVaultName : '${KeyVaultName}-${utcSuffix}'

resource KeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: targetKeyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: keyVaultSku
    }
    tenantId: tenantId
    accessPolicies: []
    enablePurgeProtection: true
    enableSoftDelete: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: allowedIps
      virtualNetworkRules: [
        {
          id: privateEndpointSubnetId
        }
      ]
    }
  }
  tags: {
    environment: environment
  }
}

resource targetKeyVaultName_pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${targetKeyVaultName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${targetKeyVaultName}-connection'
        properties: {
          privateLinkServiceId: KeyVault.id
          groupIds: [
            'vault'
          ]
          requestMessage: 'Auto-Approved'
        }
      }
    ]
  }
  tags: {
    environment: environment
  }
}

resource privatelink_vaultcore_azure_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  properties: {}
  tags: {
    environment: environment
  }
}

resource privatelink_vaultcore_azure_net_dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelink_vaultcore_azure_net
  name: dnsLinkName
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource KeyVaultName_pe_keyvault_dns_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: targetKeyVaultName_pe
  name: 'keyvault-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'keyvault-dns'
        properties: {
          privateDnsZoneId: privatelink_vaultcore_azure_net.id
        }
      }
    ]
  }
}

output kvName string = targetKeyVaultName
output keyVaultResourceId string = KeyVault.id

output keyVaultExists bool = keyVaultExists
output existingKeyVaultName string = existingKeyVaultName
output targetKeyVaultName string = targetKeyVaultName
