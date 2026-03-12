output "app_service_id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "App Service default hostname"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_identity_principal_id" {
  description = "App Service managed identity principal ID"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}
