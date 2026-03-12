# Setup Guide

## Prerequisites

- Azure subscription with Owner or Contributor role
- Azure CLI >= 2.50
- Terraform >= 1.5
- Docker (for local development)
- GitHub account

## Step 1: Fork / Clone

```bash
git clone https://github.com/yourusername/azure-ai-project-template.git
cd azure-ai-project-template
```

## Step 2: Configure Azure Authentication

### For local development

```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

### For GitHub Actions (OIDC — recommended)

1. Create an Azure AD app registration
2. Add federated credentials for your GitHub repo
3. Set these GitHub secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`

```bash
# Create app registration
az ad app create --display-name "github-ai-project-deploy"

# Create service principal
az ad sp create --id <APP_ID>

# Assign Contributor role
az role assignment create \
  --assignee <APP_ID> \
  --role "Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>"

# Add federated credential
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<OWNER>/<REPO>:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Step 3: Configure Remote State (optional but recommended)

```bash
# Create storage for Terraform state
az group create -n rg-terraform-state -l swedencentral

az storage account create \
  -n stterraformstate \
  -g rg-terraform-state \
  -l swedencentral \
  --sku Standard_LRS

az storage container create \
  -n tfstate \
  --account-name stterraformstate
```

Then uncomment the backend block in `terraform/backend.tf`.

## Step 4: Deploy Infrastructure

```bash
cd terraform/environments/dev

# Initialize
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
```

## Step 5: Build and Deploy Application

```bash
# Build locally
cd app
docker build -t myaiproject:local .

# Test locally
docker run -p 8000:8000 myaiproject:local

# Verify
curl http://localhost:8000/health
```

For automated deployment, push to `main` branch and let GitHub Actions handle it.

## Step 6: Verify Deployment

```bash
# Check App Service health
APP_URL=$(terraform output -raw app_service_url)
curl "$APP_URL/health"

# Check AI endpoint
az cognitiveservices account show \
  -n myaiproject-dev-ais \
  -g rg-myaiproject-dev \
  --query "properties.provisioningState"
```

## Customization

### Change project name

Update `project_name` in `terraform/environments/dev/variables.tf`.

### Change region

Update `location` in `terraform/environments/dev/variables.tf`. Ensure the region supports Azure AI Services and the models you need.

### Add new model deployment

Edit the `model_deployments` map in `terraform/environments/dev/main.tf`:

```hcl
model_deployments = {
  "gpt-4o" = {
    model_name    = "gpt-4o"
    model_version = "2024-08-06"
    sku_name      = "GlobalStandard"
    capacity      = 10
  }
  "text-embedding" = {
    model_name    = "text-embedding-ada-002"
    model_version = "2"
    sku_name      = "Standard"
    capacity      = 10
  }
}
```

### Add environment

1. Copy `terraform/environments/dev/` to a new folder
2. Update `local.environment`
3. Adjust SKUs and settings for the new environment
4. Add corresponding GitHub environment with secrets
