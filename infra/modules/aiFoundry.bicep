// AI Foundry (Azure AI Studio) module
@description('The name of the AI Foundry hub')
param name string

@description('The location for the AI Foundry hub')
param location string

@description('The friendly name for the AI Foundry hub')
param friendlyName string = name

@description('The description for the AI Foundry hub')
param description string = 'AI Foundry hub for ZavaStorefront'

@description('Storage account ID for the hub')
param storageAccountId string

@description('Key Vault ID for the hub')
param keyVaultId string

@description('Application Insights ID for the hub')
param applicationInsightsId string

@description('Container Registry ID for the hub')
param containerRegistryId string

@description('Tags for the AI Foundry hub')
param tags object = {}

resource aiFoundryHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: friendlyName
    description: description
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    publicNetworkAccess: 'Enabled'
  }
  kind: 'Hub'
}

@description('The ID of the AI Foundry hub')
output id string = aiFoundryHub.id

@description('The name of the AI Foundry hub')
output name string = aiFoundryHub.name

@description('The principal ID of the system assigned identity')
output principalId string = aiFoundryHub.identity.principalId
