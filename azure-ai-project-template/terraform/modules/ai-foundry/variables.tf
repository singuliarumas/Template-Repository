variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "ai_services_sku" {
  description = "SKU for AI Services account"
  type        = string
  default     = "S0"
}

variable "storage_account_id" {
  description = "Storage Account ID for AI Foundry Hub"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for AI Foundry Hub"
  type        = string
}

variable "model_deployments" {
  description = "Map of model deployments to create"
  type = map(object({
    model_name    = string
    model_version = string
    sku_name      = string
    capacity      = number
  }))
  default = {
    "gpt-4o" = {
      model_name    = "gpt-4o"
      model_version = "2024-08-06"
      sku_name      = "GlobalStandard"
      capacity      = 10
    }
  }
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for Private Endpoint (null to skip)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for AI Services"
  type        = list(string)
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
