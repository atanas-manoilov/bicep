@description('The Azure Container Registry resource.')
param acrResourceId string

@description('The Principal ID of the User Assigned Managed Identity (UAMI).')
param principalId string

// Extract the resource name from the resource ID
var acrName = last(split(acrResourceId, '/')) // Last segment is the resource name

// Declare the existing resource with full scope
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: acrName
}

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: acrResource
  name: guid(acrResourceId, principalId, 'AcrPull')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    )
    principalId: principalId
  }
}
