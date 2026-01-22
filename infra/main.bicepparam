// Parameters file for main.bicep
using './main.bicep'

// Environment configuration
param environmentName = 'dev'
param location = 'westus3'
param namePrefix = 'zavastore'
param dockerImageTag = 'latest'

// Principal ID parameter (can be overridden during deployment)
param principalId = ''
