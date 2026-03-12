# Production Environment
#
# Copy main.tf, variables.tf, and outputs.tf from dev/ and adjust:
#   - local.environment = "prod"
#   - App Service SKU: P1v3 or higher
#   - Enable purge protection on Key Vault
#   - Storage Account replication: GRS
#   - Log Analytics retention: 90+ days
#   - AI Services: public_network_access = false
#   - Consider adding Azure Front Door for traffic management
#   - Enable staging slot for blue-green deployments
#
# Example tfvars:
#   project_name = "myaiproject"
#   location     = "swedencentral"
