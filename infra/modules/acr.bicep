// Azure Container Registry module
@description('The name of the Container Registry')
param name string

@description('The location for the Container Registry')
param location string

@description('The SKU of the Container Registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user for the Container Registry')
param adminUserEnabled bool = false

@description('Tags for the Container Registry')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  tags: tags
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
  }
}

@description('The ID of the Container Registry')
output id string = containerRegistry.id

@description('The name of the Container Registry')
output name string = containerRegistry.name

@description('The login server of the Container Registry')
output loginServer string = containerRegistry.properties.loginServer
