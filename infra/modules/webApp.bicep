// Web App (App Service) module for Containers
@description('The name of the Web App')
param name string

@description('The location for the Web App')
param location string

@description('The ID of the App Service Plan')
param appServicePlanId string

@description('The login server of the Container Registry')
param containerRegistryLoginServer string

@description('The Docker image and tag')
param dockerImageAndTag string

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Tags for the Web App')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${dockerImageAndTag}'
      acrUseManagedIdentityCreds: true
      alwaysOn: false // Set to false for Basic tier
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
      ]
    }
  }
}

@description('The ID of the Web App')
output id string = webApp.id

@description('The name of the Web App')
output name string = webApp.name

@description('The default hostname of the Web App')
output defaultHostName string = webApp.properties.defaultHostName

@description('The principal ID of the system assigned identity')
output principalId string = webApp.identity.principalId
