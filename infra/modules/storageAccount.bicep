// Storage Account module (for AI Foundry)
@description('The name of the Storage Account')
param name string

@description('The location for the Storage Account')
param location string

@description('The SKU of the Storage Account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param sku string = 'Standard_LRS'

@description('Tags for the Storage Account')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

@description('The ID of the Storage Account')
output id string = storageAccount.id

@description('The name of the Storage Account')
output name string = storageAccount.name
