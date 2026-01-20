// Web App Module - Linux App Service for Containers
@description('The location for the Web App')
param location string = resourceGroup().location

@description('The name of the Web App')
param name string

@description('The resource ID of the App Service Plan')
param appServicePlanId string

@description('The login server of the Container Registry')
param containerRegistryLoginServer string

@description('The name of the container image')
param containerImageName string = 'zavastore:latest'

@description('The resource ID of the managed identity for ACR pull')
param managedIdentityId string

@description('Application Insights connection string')
param applicationInsightsConnectionString string = ''

@description('Tags for the Web App')
param tags object = {}

@description('The azd service name tag value')
param azdServiceName string

// Web App resource
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': azdServiceName })
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${containerImageName}'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentityId
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: union([
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ], !empty(applicationInsightsConnectionString) ? [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
      ] : [])
    }
  }
}

@description('The resource ID of the Web App')
output id string = webApp.id

@description('The name of the Web App')
output name string = webApp.name

@description('The default hostname of the Web App')
output defaultHostName string = webApp.properties.defaultHostName

@description('The system-assigned principal ID of the Web App')
output systemAssignedPrincipalId string = webApp.identity.principalId
