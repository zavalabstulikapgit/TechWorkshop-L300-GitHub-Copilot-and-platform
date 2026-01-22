// Role Assignment module for ACR (Azure Container Registry)
// This module assigns a role to a principal on an Azure Container Registry resource

@description('The principal ID to assign the role to')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

@description('The resource ID of the Azure Container Registry')
param resourceId string

@description('The principal type (ServicePrincipal, User, Group)')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string = 'ServicePrincipal'

// Extract resource name from full resource ID
// Format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{name}
var resourceIdParts = split(resourceId, '/')
var resourceName = length(resourceIdParts) >= 9 ? resourceIdParts[8] : last(resourceIdParts)

// Get reference to the ACR resource
resource targetResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceId, principalId, roleDefinitionId)
  scope: targetResource
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}

@description('The ID of the role assignment')
output id string = roleAssignment.id
