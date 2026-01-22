// Log Analytics Workspace module
@description('The name of the Log Analytics Workspace')
param name string

@description('The location for the Log Analytics Workspace')
param location string

@description('The SKU of the Log Analytics Workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('Tags for the Log Analytics Workspace')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
  }
}

@description('The ID of the Log Analytics Workspace')
output id string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics Workspace')
output name string = logAnalyticsWorkspace.name
