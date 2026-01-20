// App Service Plan Module
@description('The location for the App Service Plan')
param location string = resourceGroup().location

@description('The name of the App Service Plan')
param name string

@description('The SKU for the App Service Plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}

@description('Operating system for the App Service Plan')
@allowed([
  'Linux'
  'Windows'
])
param kind string = 'Linux'

@description('Tags for the App Service Plan')
param tags object = {}

// App Service Plan resource
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku
  properties: {
    reserved: kind == 'Linux' ? true : false
  }
}

@description('The resource ID of the App Service Plan')
output id string = appServicePlan.id

@description('The name of the App Service Plan')
output name string = appServicePlan.name
