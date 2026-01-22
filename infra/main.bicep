// Main Bicep template for ZavaStorefront infrastructure
targetScope = 'subscription'

@description('The name of the environment (e.g., dev, staging, prod)')
param environmentName string = 'dev'

@description('The primary Azure region for all resources')
param location string = 'westus3'

@description('The name prefix for all resources')
param namePrefix string = 'zavastore'

@description('The Docker image tag to deploy')
param dockerImageTag string = 'latest'

@description('The ID of the principal deploying this template')
param principalId string = ''

var resourceGroupName = 'rg-${namePrefix}-${environmentName}-${location}'
var acrName = replace('acr${namePrefix}${environmentName}${location}', '-', '')
var appServicePlanName = 'asp-${namePrefix}-${environmentName}-${location}'
var webAppName = 'app-${namePrefix}-${environmentName}-${location}'
var logAnalyticsName = 'log-${namePrefix}-${environmentName}-${location}'
var appInsightsName = 'appi-${namePrefix}-${environmentName}-${location}'
var storageAccountName = replace('st${namePrefix}${environmentName}', '-', '')
var keyVaultName = 'kv-${namePrefix}-${environmentName}'
var aiFoundryName = 'aif-${namePrefix}-${environmentName}-${location}'
var dockerImage = '${namePrefix}:${dockerImageTag}'

// AcrPull role definition ID
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

var tags = {
  Environment: environmentName
  Application: 'ZavaStorefront'
  ManagedBy: 'Bicep'
}

// Create resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'logAnalytics-deployment'
  scope: resourceGroup
  params: {
    name: logAnalyticsName
    location: location
    sku: 'PerGB2018'
    tags: tags
  }
}

// Deploy Application Insights
module appInsights 'modules/applicationInsights.bicep' = {
  name: 'appInsights-deployment'
  scope: resourceGroup
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

// Deploy Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  scope: resourceGroup
  params: {
    name: acrName
    location: location
    sku: 'Basic'
    adminUserEnabled: false
    tags: tags
  }
}

// Deploy Storage Account (for AI Foundry)
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storage-deployment'
  scope: resourceGroup
  params: {
    name: storageAccountName
    location: location
    sku: 'Standard_LRS'
    tags: tags
  }
}

// Deploy Key Vault (for AI Foundry)
module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault-deployment'
  scope: resourceGroup
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    tags: tags
  }
}

// Deploy App Service Plan
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan-deployment'
  scope: resourceGroup
  params: {
    name: appServicePlanName
    location: location
    sku: {
      name: 'B1'
      tier: 'Basic'
      size: 'B1'
      family: 'B'
      capacity: 1
    }
    tags: tags
  }
}

// Deploy Web App
module webApp 'modules/webApp.bicep' = {
  name: 'webApp-deployment'
  scope: resourceGroup
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryLoginServer: acr.outputs.loginServer
    dockerImageAndTag: dockerImage
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// Deploy AI Foundry Hub
module aiFoundry 'modules/aiFoundry.bicep' = {
  name: 'aiFoundry-deployment'
  scope: resourceGroup
  params: {
    name: aiFoundryName
    location: location
    friendlyName: 'ZavaStorefront AI Foundry Hub'
    description: 'AI Foundry hub for ZavaStorefront application with GPT-4 and Phi models'
    storageAccountId: storageAccount.outputs.id
    keyVaultId: keyVault.outputs.id
    applicationInsightsId: appInsights.outputs.id
    containerRegistryId: acr.outputs.id
    tags: tags
  }
}

// Assign AcrPull role to Web App managed identity
module roleAssignment 'modules/roleAssignment.bicep' = {
  name: 'roleAssignment-deployment'
  scope: resourceGroup
  params: {
    principalId: webApp.outputs.principalId
    roleDefinitionId: acrPullRoleDefinitionId
    resourceId: acr.outputs.id
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output webAppName string = webApp.outputs.name
output webAppUrl string = 'https://${webApp.outputs.defaultHostName}'
output appInsightsName string = appInsights.outputs.name
output aiFoundryName string = aiFoundry.outputs.name
output location string = location
