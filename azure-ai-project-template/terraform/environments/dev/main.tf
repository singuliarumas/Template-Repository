locals {
  environment  = "dev"
  project_name = var.project_name
  location     = var.location

  tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "Terraform"
  }
}

# --- Resource Group ---

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project_name}-${local.environment}"
  location = local.location
  tags     = local.tags
}

# --- Log Analytics ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.project_name}-${local.environment}-law"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# --- Storage Account (for AI Foundry) ---

resource "azurerm_storage_account" "ai" {
  name                     = replace("${local.project_name}${local.environment}st", "-", "")
  location                 = local.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

# --- Networking ---

module "networking" {
  source = "../../modules/networking"

  project_name        = local.project_name
  environment         = local.environment
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# --- Key Vault ---

module "key_vault" {
  source = "../../modules/key-vault"

  project_name               = local.project_name
  environment                = local.environment
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  private_endpoint_subnet_id = module.networking.subnet_private_endpoints_id
  private_dns_zone_id        = module.networking.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

# --- AI Foundry ---

module "ai_foundry" {
  source = "../../modules/ai-foundry"

  project_name               = local.project_name
  environment                = local.environment
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  storage_account_id         = azurerm_storage_account.ai.id
  key_vault_id               = module.key_vault.key_vault_id
  private_endpoint_subnet_id = module.networking.subnet_private_endpoints_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags

  private_dns_zone_ids = [
    module.networking.private_dns_zone_ids["privatelink.cognitiveservices.azure.com"],
    module.networking.private_dns_zone_ids["privatelink.openai.azure.com"]
  ]

  model_deployments = {
    "gpt-4o" = {
      model_name    = "gpt-4o"
      model_version = "2024-08-06"
      sku_name      = "GlobalStandard"
      capacity      = 10
    }
  }
}

# --- App Service ---

module "app_service" {
  source = "../../modules/app-service"

  project_name               = local.project_name
  environment                = local.environment
  location                   = local.location
  resource_group_name        = azurerm_resource_group.main.name
  vnet_integration_subnet_id = module.networking.subnet_app_service_id
  key_vault_uri              = module.key_vault.key_vault_uri
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags

  app_settings = {
    "AZURE_OPENAI_ENDPOINT" = module.ai_foundry.ai_services_endpoint
  }
}
