# ZavaStorefront - Azure Infrastructure Deployment Guide

This guide provides step-by-step instructions for deploying the ZavaStorefront application infrastructure to Azure using Bicep templates and Azure Developer CLI (azd).

## Overview

The infrastructure provisions the following Azure resources in the **westus3** region:

- **Resource Group**: `rg-zavastore-dev-westus3`
- **Azure Container Registry (ACR)**: For storing Docker container images
- **App Service Plan**: Linux-based B1 (Basic) tier
- **Web App**: Linux App Service configured for containers
- **Application Insights**: Application monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging
- **Storage Account**: Required for AI Foundry
- **Key Vault**: Secrets management for AI Foundry
- **AI Foundry Hub**: Azure AI Studio workspace for GPT-4 and Phi models

### Key Features

✅ **No Local Docker Required**: Container builds happen in the cloud using `az acr build`  
✅ **Managed Identity Authentication**: Web App uses system-assigned managed identity with AcrPull role (no passwords)  
✅ **Application Monitoring**: Integrated with Application Insights  
✅ **AI Integration**: Microsoft Foundry (AI Foundry) provisioned for GPT-4 and Phi access  
✅ **Infrastructure as Code**: All resources defined in modular Bicep templates  
✅ **Automated Deployments**: GitHub Actions workflow for CI/CD  

## Prerequisites

Before deploying, ensure you have:

1. **Azure Subscription** with appropriate permissions
2. **Azure CLI** (version 2.50.0 or later)
   ```bash
   az version
   az upgrade
   ```
3. **Azure Developer CLI (azd)** (optional, but recommended)
   ```bash
   # Install azd
   # Windows
   powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"
   
   # Linux/macOS
   curl -fsSL https://aka.ms/install-azd.sh | bash
   ```
4. **Bicep CLI** (installed with Azure CLI 2.20.0+)
   ```bash
   az bicep version
   ```

## Deployment Options

### Option 1: Using Azure Developer CLI (Recommended)

The simplest way to deploy is using `azd`:

```bash
# 1. Clone the repository
git clone <repository-url>
cd TechWorkshop-L300-GitHub-Copilot-and-platform

# 2. Initialize azd environment
azd init

# 3. Provision infrastructure and deploy application
azd up

# This will:
# - Create all Azure resources
# - Build the Docker image in ACR
# - Deploy the application to App Service
```

### Option 2: Using Azure CLI and Bicep

If you prefer more control, use Azure CLI directly:

```bash
# 1. Login to Azure
az login

# 2. Set your subscription
az account set --subscription <subscription-id>

# 3. Deploy the infrastructure
az deployment sub create \
  --name zavastore-deployment \
  --location westus3 \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam

# 4. Get the ACR name from outputs
ACR_NAME=$(az deployment sub show \
  --name zavastore-deployment \
  --query properties.outputs.acrName.value -o tsv)

# 5. Build and push the Docker image to ACR (cloud build - no local Docker needed)
az acr build \
  --registry $ACR_NAME \
  --image zavastore:latest \
  --file src/Dockerfile \
  src/

# 6. Get the Web App name
WEB_APP_NAME=$(az deployment sub show \
  --name zavastore-deployment \
  --query properties.outputs.webAppName.value -o tsv)

# 7. Configure Web App to use the image
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group rg-zavastore-dev-westus3 \
  --docker-custom-image-name $ACR_NAME.azurecr.io/zavastore:latest

# 8. Restart the Web App
az webapp restart \
  --name $WEB_APP_NAME \
  --resource-group rg-zavastore-dev-westus3
```

## GitHub Actions CI/CD Setup

To enable automated builds and deployments via GitHub Actions:

### 1. Create Azure Service Principal (Federated Credentials)

```bash
# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create service principal with federated credentials
az ad sp create-for-rbac \
  --name "github-zavastore-deploy" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth
```

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets → Actions):

- `AZURE_CLIENT_ID`: Application (client) ID
- `AZURE_TENANT_ID`: Directory (tenant) ID
- `AZURE_SUBSCRIPTION_ID`: Subscription ID

### 3. Set Up Federated Credentials

```bash
# Replace with your values
APP_ID="<application-id>"
REPO_OWNER="<github-username>"
REPO_NAME="<repository-name>"

az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-deploy",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$REPO_OWNER'/'$REPO_NAME':ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 4. Trigger Deployment

The workflow automatically runs on:
- Push to `main` branch (when files in `src/` change)
- Manual trigger via GitHub Actions UI

## Verifying the Deployment

After deployment completes:

```bash
# Get the Web App URL
az deployment sub show \
  --name zavastore-deployment \
  --query properties.outputs.webAppUrl.value -o tsv
```

Visit the URL in your browser to verify the application is running.

### Check Application Insights

```bash
# Get Application Insights name
APP_INSIGHTS_NAME=$(az deployment sub show \
  --name zavastore-deployment \
  --query properties.outputs.appInsightsName.value -o tsv)

# View in Azure Portal
az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group rg-zavastore-dev-westus3
```

## Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Resource Group                           │
│                  rg-zavastore-dev-westus3                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌─────────────────┐               │
│  │     ACR      │────────▶│   Web App       │               │
│  │   (Docker    │  Pulls  │  (App Service)  │               │
│  │   Registry)  │  Images │   w/ Managed    │               │
│  └──────────────┘         │    Identity     │               │
│         ▲                 └────────┬────────┘               │
│         │                          │                         │
│         │ Cloud Build              │ Sends Telemetry        │
│         │                          ▼                         │
│  ┌──────────────┐         ┌─────────────────┐               │
│  │   az acr     │         │  Application    │               │
│  │    build     │         │    Insights     │               │
│  └──────────────┘         └────────┬────────┘               │
│                                    │                         │
│                                    │ Logs to                 │
│                                    ▼                         │
│                           ┌─────────────────┐               │
│                           │ Log Analytics   │               │
│                           │   Workspace     │               │
│                           └─────────────────┘               │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              AI Foundry Hub                            │  │
│  │  (Azure AI Studio - GPT-4 & Phi Models)              │  │
│  │                                                         │  │
│  │  Dependencies:                                         │  │
│  │  • Storage Account                                     │  │
│  │  • Key Vault                                           │  │
│  │  • Application Insights                                │  │
│  │  • Container Registry                                  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Cost Estimates (Development Environment)

Approximate monthly costs for the dev environment in westus3:

| Resource | SKU | Estimated Cost/Month |
|----------|-----|---------------------|
| App Service Plan | B1 (Basic) | ~$13 |
| Azure Container Registry | Basic | ~$5 |
| Application Insights | Pay-as-you-go | ~$2-5 |
| Log Analytics | Pay-as-you-go | ~$2-3 |
| Storage Account | Standard LRS | ~$0.50 |
| Key Vault | Standard | ~$0.50 |
| AI Foundry Hub | Standard | ~$0 (base) + usage |

**Total Estimated Cost**: ~$25-30/month (excluding AI model usage)

> **Note**: AI Foundry costs depend on model usage (tokens consumed). GPT-4 and Phi model pricing applies per request.

## Updating the Application

### Via GitHub Actions (Automated)

1. Make changes to code in `src/` directory
2. Commit and push to `main` branch
3. GitHub Actions automatically builds and deploys

### Manual Update

```bash
# Get resource details
ACR_NAME=$(az acr list -g rg-zavastore-dev-westus3 --query "[0].name" -o tsv)
WEB_APP_NAME=$(az webapp list -g rg-zavastore-dev-westus3 --query "[0].name" -o tsv)

# Build new image
az acr build \
  --registry $ACR_NAME \
  --image zavastore:v2 \
  --file src/Dockerfile \
  src/

# Update Web App
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group rg-zavastore-dev-westus3 \
  --docker-custom-image-name $ACR_NAME.azurecr.io/zavastore:v2

# Restart
az webapp restart --name $WEB_APP_NAME --resource-group rg-zavastore-dev-westus3
```

## AI Foundry Configuration

### Accessing AI Foundry

1. Navigate to [Azure AI Studio](https://ai.azure.com/)
2. Select your subscription and the `aif-zavastore-dev-westus3` hub
3. Create a new project within the hub
4. Deploy GPT-4 or Phi models from the model catalog

### Verifying Model Availability in westus3

```bash
# Check available models in westus3
az cognitiveservices account list-models \
  --resource-group rg-zavastore-dev-westus3 \
  --location westus3
```

## Troubleshooting

### Web App Not Starting

```bash
# Check Web App logs
az webapp log tail --name <web-app-name> --resource-group rg-zavastore-dev-westus3

# Check container logs
az webapp log download --name <web-app-name> --resource-group rg-zavastore-dev-westus3 --log-file logs.zip
```

### ACR Authentication Issues

Verify managed identity has AcrPull role:

```bash
az role assignment list \
  --assignee <web-app-principal-id> \
  --scope <acr-id>
```

### AI Foundry Quota Issues

Check your subscription quotas:

```bash
az cognitiveservices usage list --location westus3
```

Request quota increase if needed through Azure Portal → Support.

## Cleanup

To delete all resources:

```bash
# Using azd
azd down

# Or using Azure CLI
az group delete --name rg-zavastore-dev-westus3 --yes --no-wait
```

## Additional Resources

- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)
- [App Service for Containers](https://docs.microsoft.com/azure/app-service/containers/)
- [Azure AI Foundry Documentation](https://docs.microsoft.com/azure/ai-studio/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)

## Support

For issues or questions:
- Create an issue in the repository
- Contact the development team
- Review Azure documentation

---

**Environment**: Development (westus3)  
**Last Updated**: January 2026  
**Maintained By**: Zava Labs
