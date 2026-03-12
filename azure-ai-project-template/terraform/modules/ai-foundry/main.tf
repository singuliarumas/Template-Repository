resource "azurerm_cognitive_account" "ai_services" {
  name                  = "${var.project_name}-${var.environment}-ais"
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "AIServices"
  sku_name              = var.ai_services_sku
  custom_subdomain_name = "${var.project_name}-${var.environment}-ais"

  public_network_access_enabled = var.environment == "prod" ? false : true

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = var.environment == "prod" ? "Deny" : "Allow"
  }

  tags = var.tags
}

# --- AI Foundry Hub ---

resource "azurerm_ai_foundry" "hub" {
  name                = "${var.project_name}-${var.environment}-aih"
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id
  key_vault_id        = var.key_vault_id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# --- AI Foundry Project ---

resource "azurerm_ai_foundry_project" "project" {
  name               = "${var.project_name}-${var.environment}-aip"
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.hub.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# --- Model Deployments ---

resource "azurerm_cognitive_deployment" "models" {
  for_each = var.model_deployments

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.ai_services.id

  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.capacity
  }
}

# --- Private Endpoint ---

resource "azurerm_private_endpoint" "ai_services" {
  count               = var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "${var.project_name}-${var.environment}-pe-ais"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.project_name}-${var.environment}-psc-ais"
    private_connection_resource_id = azurerm_cognitive_account.ai_services.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}

# --- Diagnostic Settings ---

resource "azurerm_monitor_diagnostic_setting" "ai_services" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.project_name}-${var.environment}-ais-diag"
  target_resource_id         = azurerm_cognitive_account.ai_services.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
  }
}
