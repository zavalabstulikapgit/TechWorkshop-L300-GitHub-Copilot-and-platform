# ZavaStorefront Infrastructure

This directory contains the Azure infrastructure as code (Bicep) templates for deploying the ZavaStorefront application.

## Architecture

The infrastructure consists of the following Azure resources:

### Core Resources
- **Resource Group**: Container for all related resources
- **Container Registry (ACR)**: Stores Docker container images
- **App Service Plan**: Linux-based hosting plan
- **App Service (Web App)**: Runs the containerized ASP.NET Core application
- **User-Assigned Managed Identity**: Used for secure ACR access

### Monitoring & Observability
- **Application Insights**: Application performance monitoring
- **Log Analytics Workspace**: Backend storage for logs and metrics

### AI/ML (Optional)
- **Azure AI Services (Foundry)**: Provides GPT-4 and Phi model access

### Security
- **System-Assigned Managed Identity**: Web App identity
- **RBAC Role Assignments**: AcrPull role for container image access
- **HTTPS Only**: All traffic encrypted
- **No Admin Credentials**: ACR uses managed identity authentication

## File Structure

```
infra/
├── main.bicep                      # Main orchestration template
├── main.parameters.json            # Parameters file
├── abbreviations.json              # Resource naming conventions
└── modules/
    ├── managed-identity.bicep      # User-assigned identity module
    ├── container-registry.bicep    # ACR module
    ├── app-service-plan.bicep     # App Service Plan module
    ├── web-app.bicep              # Web App for Containers module
    ├── monitoring.bicep           # Application Insights + Log Analytics
    ├── foundry.bicep              # Azure AI Services module
    └── role-assignment.bicep      # RBAC role assignment module
```

## Prerequisites

- Azure CLI (`az`) version 2.50.0 or later
- Azure Developer CLI (`azd`) version 1.5.0 or later
- An active Azure subscription
- Contributor or Owner role on the subscription

## Deployment Instructions

### Option 1: Using Azure Developer CLI (Recommended)

1. **Initialize AZD environment**:
   ```bash
   azd init
   ```

2. **Create a new environment**:
   ```bash
   azd env new dev
   ```

3. **Set the location** (must be westus3 for Foundry models):
   ```bash
   azd env set AZURE_LOCATION westus3
   ```

4. **Preview the deployment**:
   ```bash
   azd provision --preview
   ```

5. **Provision the infrastructure**:
   ```bash
   azd provision
   ```

6. **Deploy the application**:
   ```bash
   azd deploy
   ```

7. **Or do everything in one step**:
   ```bash
   azd up
   ```

### Option 2: Using Azure CLI

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Set your subscription**:
   ```bash
   az account set --subscription "Your Subscription Name"
   ```

3. **Create a resource group**:
   ```bash
   az group create --name rg-zavastore-dev-westus3 --location westus3
   ```

4. **Validate the template**:
   ```bash
   az deployment group validate \
     --resource-group rg-zavastore-dev-westus3 \
     --template-file main.bicep \
     --parameters environmentName=dev location=westus3
   ```

5. **Preview changes (what-if)**:
   ```bash
   az deployment group what-if \
     --resource-group rg-zavastore-dev-westus3 \
     --template-file main.bicep \
     --parameters environmentName=dev location=westus3
   ```

6. **Deploy the infrastructure**:
   ```bash
   az deployment group create \
     --resource-group rg-zavastore-dev-westus3 \
     --template-file main.bicep \
     --parameters environmentName=dev location=westus3
   ```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `environmentName` | string | (required) | Environment identifier (e.g., dev, staging, prod) |
| `location` | string | (required) | Azure region for deployment |
| `resourceGroupName` | string | '' | Resource group name (auto-generated if empty) |
| `enableFoundry` | bool | true | Deploy Azure AI Services for GPT-4 and Phi |
| `containerRegistrySku` | string | 'Basic' | ACR SKU: Basic, Standard, or Premium |
| `appServicePlanSku` | object | B1 Basic | App Service Plan configuration |
| `containerImageName` | string | 'zavastore:latest' | Container image name and tag |
| `aiModelDeployments` | array | GPT-4, Phi-3 | AI models to deploy |

## Outputs

The deployment provides the following outputs:

- `RESOURCE_GROUP_ID`: Resource group resource ID
- `AZURE_CONTAINER_REGISTRY_NAME`: ACR name
- `AZURE_CONTAINER_REGISTRY_ENDPOINT`: ACR login server URL
- `AZURE_APP_SERVICE_NAME`: Web App name
- `SERVICE_WEB_ENDPOINT`: Web App HTTPS URL
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: App Insights connection string
- `AZURE_OPENAI_ENDPOINT`: Azure AI Services endpoint
- `AZURE_OPENAI_NAME`: Azure AI Services account name

## Building and Deploying the Container

### Using Cloud Build (No local Docker required)

```bash
# Get the registry name from outputs
REGISTRY_NAME=$(az deployment group show \
  --resource-group rg-zavastore-dev-westus3 \
  --name main \
  --query properties.outputs.AZURE_CONTAINER_REGISTRY_NAME.value -o tsv)

# Build and push using Azure Container Registry
az acr build \
  --registry $REGISTRY_NAME \
  --image zavastore:latest \
  ./src
```

### Configure Web App to use the image

The Web App is automatically configured to pull from ACR using the managed identity. After building the image, restart the Web App:

```bash
az webapp restart \
  --name $(az deployment group show --resource-group rg-zavastore-dev-westus3 --name main --query properties.outputs.AZURE_APP_SERVICE_NAME.value -o tsv) \
  --resource-group rg-zavastore-dev-westus3
```

## Monitoring

### View Application Logs

```bash
az webapp log tail \
  --name <web-app-name> \
  --resource-group rg-zavastore-dev-westus3
```

### Access Application Insights

```bash
# Get the Application Insights resource
az monitor app-insights component show \
  --app <app-insights-name> \
  --resource-group rg-zavastore-dev-westus3
```

## Cost Optimization

For development environments:
- Container Registry: **Basic** SKU (~$5/month)
- App Service Plan: **B1** tier (~$13/month)
- Application Insights: Pay-as-you-go (~$2-5/month)
- Log Analytics: 5GB free tier
- Azure AI Services: Pay per usage (~$50+/month)

**Estimated monthly cost: $70-80**

## Security Best Practices

✅ **Implemented:**
- HTTPS only on Web App
- Managed Identity for ACR access (no passwords)
- System and User-Assigned identities
- RBAC-based authorization
- Minimum required permissions
- TLS 1.2 minimum
- FTPS disabled

## Cleanup

To delete all resources:

### Using AZD
```bash
azd down --purge
```

### Using Azure CLI
```bash
az group delete --name rg-zavastore-dev-westus3 --yes --no-wait
```

## Troubleshooting

### Container won't start
- Check that the container image exists in ACR
- Verify the managed identity has AcrPull role
- Review container logs: `az webapp log tail`

### Deployment fails
- Run `az deployment group what-if` to preview changes
- Check quota limits for the region
- Verify subscription permissions

### AI Services not available
- Ensure region is **westus3** (required for GPT-4/Phi)
- Check model availability: [Azure OpenAI Model Availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models)

## Additional Resources

- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Azure Application Insights Documentation](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure AI Services Documentation](https://learn.microsoft.com/azure/ai-services/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
