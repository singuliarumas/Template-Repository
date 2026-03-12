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

variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_app_service_prefix" {
  description = "App Service subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_private_endpoints_prefix" {
  description = "Private Endpoints subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_ai_foundry_prefix" {
  description = "AI Foundry subnet CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_dns_zones" {
  description = "List of Private DNS zones to create"
  type        = list(string)
  default = [
    "privatelink.vaultcore.azure.net",
    "privatelink.azurewebsites.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com"
  ]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
