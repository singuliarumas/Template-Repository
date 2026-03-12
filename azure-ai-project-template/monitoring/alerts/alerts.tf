# Alert rules for AI project monitoring
# Deploy alongside main infrastructure

variable "resource_group_name" {
  type = string
}

variable "app_service_id" {
  type = string
}

variable "ai_services_id" {
  type = string
}

variable "action_group_id" {
  description = "Action Group ID for alert notifications"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# --- App Service Alerts ---

resource "azurerm_monitor_metric_alert" "app_response_time" {
  name                = "alert-app-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "App Service response time exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HttpResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_5xx_errors" {
  name                = "alert-app-5xx-errors"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "App Service 5xx errors detected"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_health_check" {
  name                = "alert-app-health-check"
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "App Service health check failures"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# --- AI Services Alerts ---

resource "azurerm_monitor_metric_alert" "ai_latency" {
  name                = "alert-ai-latency"
  resource_group_name = var.resource_group_name
  scopes              = [var.ai_services_id]
  description         = "AI Services latency exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "Latency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10000
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "ai_errors" {
  name                = "alert-ai-client-errors"
  resource_group_name = var.resource_group_name
  scopes              = [var.ai_services_id]
  description         = "AI Services client errors (429/4xx) spike"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "ClientErrors"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "ai_availability" {
  name                = "alert-ai-availability"
  resource_group_name = var.resource_group_name
  scopes              = [var.ai_services_id]
  description         = "AI Services availability drop"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "SuccessRate"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
