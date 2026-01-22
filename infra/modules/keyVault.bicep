// Key Vault module (for AI Foundry)
@description('The name of the Key Vault')
param name string

@description('The location for the Key Vault')
param location string

@description('The tenant ID for the Key Vault')
param tenantId string = subscription().tenantId

@description('The SKU of the Key Vault')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'

@description('Tags for the Key Vault')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: sku
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
}

@description('The ID of the Key Vault')
output id string = keyVault.id

@description('The name of the Key Vault')
output name string = keyVault.name

@description('The URI of the Key Vault')
output vaultUri string = keyVault.properties.vaultUri
