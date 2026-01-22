// App Service Plan module
@description('The name of the App Service Plan')
param name string

@description('The location for the App Service Plan')
param location string

@description('The SKU of the App Service Plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  family: 'B'
  capacity: 1
}

@description('Tags for the App Service Plan')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  sku: sku
  kind: 'linux'
  tags: tags
  properties: {
    reserved: true // Required for Linux
  }
}

@description('The ID of the App Service Plan')
output id string = appServicePlan.id

@description('The name of the App Service Plan')
output name string = appServicePlan.name
