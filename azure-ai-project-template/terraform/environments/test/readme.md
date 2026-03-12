# Test Environment
#
# Copy main.tf, variables.tf, and outputs.tf from dev/ and adjust:
#   - local.environment = "test"
#   - Increase App Service SKU if needed (e.g., S1)
#   - Consider adding test-specific model deployments
#
# Example tfvars:
#   project_name = "myaiproject"
#   location     = "swedencentral"
