// Application Insights module
@description('The name of Application Insights')
param name string

@description('The location for Application Insights')
param location string

@description('The ID of the Log Analytics Workspace')
param workspaceResourceId string

@description('Tags for Application Insights')
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceResourceId
    Flow_Type: 'Bluefield'
  }
}

@description('The ID of Application Insights')
output id string = applicationInsights.id

@description('The name of Application Insights')
output name string = applicationInsights.name

@description('The instrumentation key of Application Insights')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string of Application Insights')
output connectionString string = applicationInsights.properties.ConnectionString
