# Quick Start Guide - ZavaStorefront Azure Deployment

## 🚀 Fast Track Deployment

### Prerequisites Check
```bash
az version  # Ensure Azure CLI is installed
az login    # Login to Azure
```

### Deploy Everything (One Command)
```bash
# Install Azure Developer CLI if not already installed
curl -fsSL https://aka.ms/install-azd.sh | bash  # Linux/Mac
# OR
powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"  # Windows

# Deploy
cd TechWorkshop-L300-GitHub-Copilot-and-platform
azd up
```

That's it! 🎉

### What Gets Deployed?

✅ Resource Group: `rg-zavastore-dev-westus3`  
✅ Container Registry (ACR)  
✅ Web App (Linux + Docker)  
✅ Application Insights  
✅ AI Foundry Hub (for GPT-4/Phi)  
✅ Supporting services (Storage, Key Vault, Log Analytics)  

### Access Your App

After deployment:
```bash
# Get the URL
azd env get-values | grep WEB_APP_URL

# Or using Azure CLI
az webapp list -g rg-zavastore-dev-westus3 --query "[0].defaultHostName" -o tsv
```

Visit: `https://<your-app-name>.azurewebsites.net`

## 📝 Common Commands

### Update Application Code
```bash
# Make your code changes in src/
# Then rebuild and redeploy
ACR_NAME=$(az acr list -g rg-zavastore-dev-westus3 --query "[0].name" -o tsv)
az acr build --registry $ACR_NAME --image zavastore:latest src/

# Restart web app
WEB_APP=$(az webapp list -g rg-zavastore-dev-westus3 --query "[0].name" -o tsv)
az webapp restart -n $WEB_APP -g rg-zavastore-dev-westus3
```

### View Logs
```bash
az webapp log tail -n $WEB_APP -g rg-zavastore-dev-westus3
```

### Cleanup
```bash
azd down  # Deletes everything
# OR
az group delete -n rg-zavastore-dev-westus3 --yes
```

## 💰 Cost

~$25-30/month for dev environment (excluding AI usage)

## 📚 More Details

See [DEPLOYMENT.md](./DEPLOYMENT.md) for comprehensive documentation.
