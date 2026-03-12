output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "app_service_url" {
  value = "https://${module.app_service.app_service_default_hostname}"
}

output "ai_services_endpoint" {
  value = module.ai_foundry.ai_services_endpoint
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}
