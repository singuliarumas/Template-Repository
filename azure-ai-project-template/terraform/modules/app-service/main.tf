resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-${var.environment}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                      = "${var.project_name}-${var.environment}-app"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  service_plan_id           = azurerm_service_plan.main.id
  https_only                = true
  virtual_network_subnet_id = var.vnet_integration_subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on              = var.environment == "prod" ? true : false
    ftps_state             = "Disabled"
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true

    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = var.docker_registry_url
    }

    health_check_path = var.health_check_path
  }

  app_settings = merge(
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "DOCKER_ENABLE_CI"                    = "true"
      "AZURE_KEY_VAULT_URI"                 = var.key_vault_uri
    },
    var.app_settings
  )

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
    application_logs {
      file_system_level = "Warning"
    }
  }

  tags = var.tags
}

# --- Staging Slot (prod only) ---

resource "azurerm_linux_web_app_slot" "staging" {
  count          = var.environment == "prod" ? 1 : 0
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id
  https_only     = true

  site_config {
    always_on           = true
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"

    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = var.docker_registry_url
    }

    health_check_path = var.health_check_path
  }

  app_settings = merge(
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "AZURE_KEY_VAULT_URI"                 = var.key_vault_uri
    },
    var.app_settings
  )

  tags = var.tags
}

# --- Diagnostic Settings ---

resource "azurerm_monitor_diagnostic_setting" "app_service" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.project_name}-${var.environment}-app-diag"
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
