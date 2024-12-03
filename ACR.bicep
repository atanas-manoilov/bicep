@description('Name of the Azure Container Registry.')
param ACR_name string = 'amanilov021'

@description('Location of the Azure Container Registry.')
param location string = resourceGroup().location

@description('SKU of the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Specifies whether the admin user is enabled on the ACR.')
param admin_enabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: ACR_name
  location: location
  properties: {
    adminUserEnabled: admin_enabled
  }
  sku: {
    name: sku
  }
}

output acrName string = ACR_name
output acrVaultId string = acr.id
