@description('Resource ID of the Key Vault.')
param keyVaultResourceId string

@description('List of custom object IDs to grant access.')
param customObjectIds array

resource keyVaultResourceId_8_add 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${split(keyVaultResourceId,'/')[8]}/add'
  properties: {
    accessPolicies: [
      for item in customObjectIds: {
        objectId: item
        permissions: {
          keys: [
            'Get'
            'List'
          ]
          secrets: [
            'Get'
            'List'
          ]
          certificates: [
            'Get'
            'List'
            'Import'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}
