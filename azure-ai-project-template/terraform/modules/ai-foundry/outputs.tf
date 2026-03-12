output "ai_services_id" {
  description = "AI Services account ID"
  value       = azurerm_cognitive_account.ai_services.id
}

output "ai_services_endpoint" {
  description = "AI Services endpoint"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "ai_foundry_hub_id" {
  description = "AI Foundry Hub ID"
  value       = azurerm_ai_foundry.hub.id
}

output "ai_foundry_project_id" {
  description = "AI Foundry Project ID"
  value       = azurerm_ai_foundry_project.project.id
}

output "model_deployment_ids" {
  description = "Map of model deployment names to IDs"
  value       = { for k, v in azurerm_cognitive_deployment.models : k => v.id }
}
