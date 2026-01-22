// Role Assignment module
@description('The principal ID to assign the role to')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

@description('The resource ID to assign the role on')
param resourceId string

@description('The principal type (ServicePrincipal, User, Group)')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string = 'ServicePrincipal'

// Get reference to the resource
resource targetResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: last(split(resourceId, '/'))
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
