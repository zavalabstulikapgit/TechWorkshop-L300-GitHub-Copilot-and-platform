# TechWorkshop L300 - GitHub Copilot and Azure Platform

This lab guides you through a series of practical exercises focused on modernising Zava's business applications and databases by migrating everything to Azure, leveraging GitHub Enterprise, Copilot, and Azure services. Each exercise is designed to deliver hands-on experience in governance, automation, security, AI integration, and observability, ensuring Zava's transition to Azure is robust, secure, and future-ready.

## ZavaStorefront Application

This repository contains the **ZavaStorefront** - a sample ASP.NET Core MVC e-commerce application that demonstrates modern cloud-native deployment practices on Azure.

### Features

- 🛒 E-commerce storefront with product catalog and shopping cart
- 🐳 Containerized deployment using Docker
- ☁️ Azure infrastructure provisioned via Bicep (Infrastructure as Code)
- 🔐 Managed identity authentication (no passwords)
- 📊 Application Insights monitoring
- 🤖 AI Foundry integration for GPT-4 and Phi models
- 🚀 Automated CI/CD with GitHub Actions

### Quick Start

Deploy the complete infrastructure and application to Azure:

```bash
# Install Azure Developer CLI
curl -fsSL https://aka.ms/install-azd.sh | bash

# Deploy everything
azd up
```

📚 **Documentation:**
- [Quick Start Guide](QUICKSTART.md) - Get started in 5 minutes
- [Deployment Guide](DEPLOYMENT.md) - Comprehensive deployment documentation
- [Application README](src/README.md) - Application details and features

### Repository Structure

```
TechWorkshop-L300-GitHub-Copilot-and-platform/
├── infra/                      # Azure infrastructure (Bicep templates)
│   ├── main.bicep             # Main infrastructure template
│   ├── main.bicepparam        # Parameters file
│   └── modules/               # Modular Bicep templates
│       ├── acr.bicep          # Azure Container Registry
│       ├── appServicePlan.bicep
│       ├── webApp.bicep       # Linux App Service
│       ├── applicationInsights.bicep
│       ├── aiFoundry.bicep    # AI Foundry Hub
│       └── ...
├── src/                       # ZavaStorefront application
│   ├── Dockerfile             # Container definition
│   ├── Program.cs
│   └── ...
├── .github/workflows/         # CI/CD pipelines
│   └── build-and-push-acr.yml # ACR build workflow
├── azure.yaml                 # Azure Developer CLI config
├── DEPLOYMENT.md              # Detailed deployment guide
└── QUICKSTART.md              # Quick start guide
```

### Azure Resources Deployed

The infrastructure provisions the following resources in **westus3**:

| Resource | Purpose | SKU |
|----------|---------|-----|
| Resource Group | Container for all resources | N/A |
| Container Registry | Docker image storage | Basic |
| App Service Plan | Hosting infrastructure | B1 (Linux) |
| Web App | Application hosting | Linux Containers |
| Application Insights | Monitoring & telemetry | Pay-as-you-go |
| Log Analytics | Centralized logging | PerGB2018 |
| AI Foundry Hub | Azure AI Studio workspace | Standard |
| Storage Account | AI Foundry dependency | Standard LRS |
| Key Vault | Secrets management | Standard |

**Estimated Cost**: ~$25-30/month (dev environment)

### Key Technical Highlights

✅ **No Local Docker Required** - Container builds use `az acr build` (cloud-based)  
✅ **Managed Identity** - Web App authenticates to ACR using system-assigned identity with AcrPull role  
✅ **Infrastructure as Code** - All resources defined in modular Bicep templates  
✅ **Automated Deployments** - GitHub Actions workflow for CI/CD  
✅ **AI-Ready** - Microsoft Foundry provisioned for GPT-4 and Phi model access

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
