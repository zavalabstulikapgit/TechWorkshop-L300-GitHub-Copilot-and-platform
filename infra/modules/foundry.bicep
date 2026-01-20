// Microsoft Foundry (Azure AI Services) Module
@description('The location for the AI Services account')
param location string = resourceGroup().location

@description('The name of the AI Services account')
param name string

@description('The SKU for the AI Services account')
param sku object = {
  name: 'S0'
}

@description('Tags for the AI Services account')
param tags object = {}

@description('Model deployments to create')
param modelDeployments array = []

// AI Services Account resource
resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  sku: sku
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Model Deployments
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for model in modelDeployments: {
  parent: aiServices
  name: model.name
  sku: {
    name: 'Standard'
    capacity: model.capacity ?? 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: model.modelName
      version: model.version
    }
  }
}]

@description('The resource ID of the AI Services account')
output id string = aiServices.id

@description('The name of the AI Services account')
output name string = aiServices.name

@description('The endpoint of the AI Services account')
output endpoint string = aiServices.properties.endpoint
