# GitHub Actions Deployment Configuration

This workflow builds the containerized .NET application and deploys it to Azure App Service.

## Required GitHub Secrets

### 1. AZURE_CREDENTIALS

Create an Azure Service Principal with Contributor access:

```bash
az ad sp create-for-rbac \
  --name "github-actions-zavastore" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
  --sdk-auth
```

Copy the entire JSON output and add it as a secret named `AZURE_CREDENTIALS`.

## Required GitHub Variables

Add these as **repository variables** (Settings → Secrets and variables → Actions → Variables):

| Variable Name | Description | Example Value |
|--------------|-------------|---------------|
| `AZURE_CONTAINER_REGISTRY_NAME` | ACR name (without .azurecr.io) | `acr123abc456def` |
| `AZURE_APP_SERVICE_NAME` | Web App name | `app123abc456def` |
| `AZURE_RESOURCE_GROUP` | Resource group name | `rg-dev` |

## Getting the Values

After running `azd up`, get the values:

```bash
# Container Registry Name
azd env get-value AZURE_CONTAINER_REGISTRY_NAME

# App Service Name
azd env get-value AZURE_APP_SERVICE_NAME

# Resource Group (constructed from environment name)
echo "rg-$(azd env get-value AZURE_ENV_NAME)"
```

## Setup Steps

1. **Create Service Principal**: Run the command above with your subscription and resource group
2. **Add Secret**: GitHub repo → Settings → Secrets and variables → Actions → New repository secret
   - Name: `AZURE_CREDENTIALS`
   - Value: Paste the JSON from step 1
3. **Add Variables**: Same location → Variables tab → New repository variable
   - Add each variable from the table above

## Trigger Deployment

The workflow runs automatically on push to `main` or manually via Actions tab → Build and Deploy to Azure → Run workflow.
