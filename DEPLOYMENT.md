# ZavaStorefront - Azure Deployment Guide

This guide provides step-by-step instructions for deploying the ZavaStorefront application to Azure using the infrastructure as code files.

## 📋 Prerequisites

Before you begin, ensure you have:

- [ ] **Azure Subscription** with Contributor or Owner role
- [ ] **Azure CLI** (az) version 2.50.0 or later - [Install](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [ ] **Azure Developer CLI** (azd) version 1.5.0 or later - [Install](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [ ] **Git** for version control
- [ ] Active internet connection

## 🎯 Quick Start

Deploy everything in 3 steps:

```bash
# 1. Initialize and login
azd auth login

# 2. Create environment
azd env new dev

# 3. Deploy everything
azd up
```

## 📁 Project Structure

```
TechWorkshop-L300-GitHub-Copilot-and-platform/
├── azure.yaml                  # AZD configuration
├── infra/                      # Infrastructure as Code
│   ├── main.bicep             # Main template
│   ├── main.parameters.json   # Parameters
│   ├── abbreviations.json     # Naming conventions
│   ├── README.md              # Infrastructure docs
│   └── modules/               # Bicep modules
│       ├── managed-identity.bicep
│       ├── container-registry.bicep
│       ├── app-service-plan.bicep
│       ├── web-app.bicep
│       ├── monitoring.bicep
│       ├── foundry.bicep
│       └── role-assignment.bicep
└── src/                       # Application source
    ├── Dockerfile             # Container definition
    └── ZavaStorefront/        # ASP.NET Core app
```

## 🚀 Detailed Deployment Steps

### Step 1: Verify Prerequisites

```powershell
# Check Azure CLI
az --version

# Check Azure Developer CLI
azd version

# Verify you're logged in
az account show
```

### Step 2: Login to Azure

```bash
# Login to Azure
az login

# Login to AZD
azd auth login

# Set your subscription (if you have multiple)
az account set --subscription "Your Subscription Name"
```

### Step 3: Initialize AZD Environment

```bash
# Navigate to project root
cd TechWorkshop-L300-GitHub-Copilot-and-platform

# Create a new environment
azd env new dev

# Set the Azure location (MUST be westus3 for AI models)
azd env set AZURE_LOCATION westus3
```

### Step 4: Preview the Deployment

```bash
# Preview what will be created
azd provision --preview
```

This shows you:
- All resources that will be created
- Estimated costs
- Configuration settings

### Step 5: Provision Infrastructure

```bash
# Create all Azure resources
azd provision
```

This will:
- ✅ Create resource group
- ✅ Deploy Container Registry
- ✅ Create App Service Plan
- ✅ Deploy Web App
- ✅ Configure managed identities
- ✅ Set up monitoring (Application Insights)
- ✅ Deploy Azure AI Services (optional)
- ✅ Assign RBAC roles

**⏱️ Duration: 5-10 minutes**

### Step 6: Build and Deploy Application

The AZD hooks will automatically:

```bash
# Build container image in Azure (no local Docker needed)
# Deploy to App Service
azd deploy
```

Or do steps 5 & 6 together:

```bash
azd up
```

### Step 7: Verify Deployment

```bash
# Get the application URL
azd env get-values | findstr SERVICE_WEB_ENDPOINT

# Open in browser
start $(azd env get-value SERVICE_WEB_ENDPOINT)
```

## 🔧 Configuration Options

### Change Deployment Region

```bash
# Default is westus3 (required for AI models)
azd env set AZURE_LOCATION eastus
```

### Disable Azure AI Services

Edit `infra/main.bicep`:
```bicep
param enableFoundry bool = false  // Change to false
```

### Change App Service SKU

Edit `infra/main.bicep`:
```bicep
param appServicePlanSku object = {
  name: 'B2'    // Change from B1 to B2 for more resources
  tier: 'Basic'
  capacity: 1
}
```

### Change Container Registry SKU

```bash
azd env set CONTAINER_REGISTRY_SKU Standard
```

## 🔍 Monitoring & Troubleshooting

### View Application Logs

```bash
# Get web app name
$webAppName = azd env get-value AZURE_APP_SERVICE_NAME

# Stream logs
az webapp log tail --name $webAppName --resource-group rg-dev
```

### Check Container Status

```bash
# View container logs
az webapp log download --name $webAppName --resource-group rg-dev
```

### Access Application Insights

```bash
# Get resource group name
$rgName = "rg-" + (azd env get-value AZURE_ENV_NAME)

# Open Application Insights in portal
az monitor app-insights component show --app appi* --resource-group $rgName --query id -o tsv | % { start "https://portal.azure.com/#@/resource/$_" }
```

### Common Issues

#### Container won't start
```bash
# Check if image exists in ACR
az acr repository list --name $(azd env get-value AZURE_CONTAINER_REGISTRY_NAME)

# Restart the web app
az webapp restart --name $(azd env get-value AZURE_APP_SERVICE_NAME) --resource-group rg-dev
```

#### Deployment fails
```bash
# Check deployment logs
azd provision --debug
```

#### AI Services not available
- Ensure region is **westus3**
- Check [model availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models)

## 🔐 Security Features

The deployment implements these security best practices:

- ✅ **Managed Identity**: No passwords for ACR access
- ✅ **HTTPS Only**: All traffic encrypted
- ✅ **RBAC**: Role-based access control
- ✅ **TLS 1.2+**: Minimum TLS version enforced
- ✅ **FTPS Disabled**: Secure file transfer only
- ✅ **Application Insights**: Security monitoring
- ✅ **Key Vault Ready**: Infrastructure supports Key Vault integration

## 💰 Cost Management

### Estimated Monthly Costs (Dev Environment)

| Resource | SKU | Cost |
|----------|-----|------|
| App Service Plan | B1 | ~$13 |
| Container Registry | Basic | ~$5 |
| Application Insights | Pay-as-you-go | ~$2-5 |
| Log Analytics | 5GB included | ~$0-5 |
| Azure AI Services | S0 | ~$50+ (usage) |
| **Total** | | **~$70-80** |

### Stop Resources to Save Costs

```bash
# Stop the web app (saves compute costs)
az webapp stop --name $(azd env get-value AZURE_APP_SERVICE_NAME) --resource-group rg-dev
```

### Delete Everything

```bash
# Remove all resources and configurations
azd down --purge
```

## 🔄 CI/CD Integration

### GitHub Actions (Coming Soon)

The infrastructure is ready for GitHub Actions deployment:

1. Set up Azure Service Principal
2. Configure GitHub secrets
3. Use the provided workflow template

## 📊 Environment Variables

View all environment variables:

```bash
azd env get-values
```

Key variables:
- `AZURE_ENV_NAME`: Your environment name
- `AZURE_LOCATION`: Deployment region
- `AZURE_CONTAINER_REGISTRY_NAME`: ACR name
- `SERVICE_WEB_ENDPOINT`: Application URL
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Monitoring connection

## 🆘 Getting Help

- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Application Insights Documentation](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)

## ✅ Deployment Checklist

- [ ] Azure CLI installed and logged in
- [ ] AZD installed and logged in
- [ ] Subscription selected
- [ ] Environment created (`azd env new`)
- [ ] Location set to westus3
- [ ] Infrastructure provisioned (`azd provision`)
- [ ] Application deployed (`azd deploy`)
- [ ] Application URL tested
- [ ] Monitoring configured
- [ ] Logs accessible

## 🎉 Success!

Your ZavaStorefront application is now running on Azure with:
- ✅ Containerized deployment
- ✅ Managed identity security
- ✅ Application monitoring
- ✅ AI capabilities (optional)
- ✅ Production-ready infrastructure

Access your application at the URL shown in the deployment output!
