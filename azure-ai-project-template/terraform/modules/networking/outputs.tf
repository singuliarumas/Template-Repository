output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "subnet_app_service_id" {
  description = "App Service subnet ID"
  value       = azurerm_subnet.app_service.id
}

output "subnet_private_endpoints_id" {
  description = "Private Endpoints subnet ID"
  value       = azurerm_subnet.private_endpoints.id
}

output "subnet_ai_foundry_id" {
  description = "AI Foundry subnet ID"
  value       = azurerm_subnet.ai_foundry.id
}

output "private_dns_zone_ids" {
  description = "Map of Private DNS zone names to IDs"
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}
