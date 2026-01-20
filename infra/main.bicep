// Main Bicep template for ZavaStorefront infrastructure
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Enable Microsoft Foundry (Azure AI Services) deployment')
param enableFoundry bool = true

@description('SKU for the Container Registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param containerRegistrySku string = 'Basic'

@description('SKU for the App Service Plan')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}

@description('Container image name and tag')
param containerImageName string = 'zavastore:latest'

@description('AI model deployments to create')
param aiModelDeployments array = [
  {
    name: 'gpt-4o'
    modelName: 'gpt-4o'
    version: '2024-05-13'
    capacity: 10
  }
]

// Generate a unique token for resource naming
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)
var tags = {
  'azd-env-name': environmentName
}

// Resource names following AZD naming conventions
var abbrs = loadJsonContent('abbreviations.json')
var managedIdentityName = 'id${resourceToken}'
var containerRegistryName = 'acr${resourceToken}'
var appServicePlanName = '${abbrs.resources.appServicePlan}${resourceToken}'
var webAppName = 'app${resourceToken}'
var applicationInsightsName = '${abbrs.resources.applicationInsights}${resourceToken}'
var logAnalyticsWorkspaceName = '${abbrs.resources.logAnalyticsWorkspace}${resourceToken}'
var aiServicesName = 'ai${resourceToken}'

// Built-in role definition IDs
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// User-Assigned Managed Identity (required by AZD)
module managedIdentity 'modules/managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    name: managedIdentityName
    location: location
    tags: tags
  }
}

// Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'container-registry-deployment'
  params: {
    name: containerRegistryName
    location: location
    sku: containerRegistrySku
    adminUserEnabled: false
    tags: tags
  }
}

// Monitoring resources (Application Insights + Log Analytics)
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    applicationInsightsName: applicationInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
    tags: tags
  }
}

// App Service Plan
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'app-service-plan-deployment'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
    kind: 'Linux'
    tags: tags
  }
}

// Web App (App Service for Containers)
module webApp 'modules/web-app.bicep' = {
  name: 'web-app-deployment'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryLoginServer: containerRegistry.outputs.loginServer
    containerImageName: containerImageName
    managedIdentityId: managedIdentity.outputs.id
    applicationInsightsConnectionString: monitoring.outputs.connectionString
    azdServiceName: 'web'
    tags: tags
  }
}

// Role Assignment: Grant Web App's system-assigned identity AcrPull role on ACR
module acrPullRoleAssignment 'modules/role-assignment.bicep' = {
  name: 'acr-pull-role-assignment'
  params: {
    principalId: webApp.outputs.systemAssignedPrincipalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Grant User-Assigned Managed Identity AcrPull role on ACR
module acrPullUserIdentityRoleAssignment 'modules/role-assignment.bicep' = {
  name: 'acr-pull-user-identity-role-assignment'
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

// Microsoft Foundry (Azure AI Services) - Optional
module foundry 'modules/foundry.bicep' = if (enableFoundry) {
  name: 'foundry-deployment'
  params: {
    name: aiServicesName
    location: location
    sku: {
      name: 'S0'
    }
    modelDeployments: aiModelDeployments
    tags: tags
  }
}

// Outputs required by AZD
@description('The resource ID of the resource group')
output RESOURCE_GROUP_ID string = resourceGroup().id

@description('The name of the Container Registry')
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name

@description('The login server of the Container Registry')
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

@description('The name of the Web App')
output AZURE_APP_SERVICE_NAME string = webApp.outputs.name

@description('The default hostname of the Web App')
output SERVICE_WEB_ENDPOINT string = 'https://${webApp.outputs.defaultHostName}'

@description('Application Insights connection string')
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.connectionString

@description('Azure AI Services endpoint')
output AZURE_OPENAI_ENDPOINT string = enableFoundry ? foundry.?outputs.?endpoint ?? '' : ''

@description('The name of the Azure AI Services account')
output AZURE_OPENAI_NAME string = enableFoundry ? foundry.?outputs.?name ?? '' : ''
