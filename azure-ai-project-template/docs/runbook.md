# Runbook

## Incident Response

### App Service returning 5xx errors

1. Check App Service logs:
   ```bash
   az webapp log tail -n myaiproject-dev-app -g rg-myaiproject-dev
   ```
2. Check container health:
   ```bash
   az webapp show -n myaiproject-dev-app -g rg-myaiproject-dev \
     --query "properties.state"
   ```
3. Restart if needed:
   ```bash
   az webapp restart -n myaiproject-dev-app -g rg-myaiproject-dev
   ```
4. If persists, check recent deployments and consider rollback.

### AI Services returning 429 (throttled)

1. Check current usage in Azure Portal → AI Services → Metrics → Requests
2. Review token consumption using KQL query from `monitoring/diagnostics/kql-queries.md`
3. Options:
   - Increase deployment capacity in Terraform
   - Add retry logic with exponential backoff in application
   - Switch to a different deployment SKU

### AI Services latency spike

1. Check Azure status page for regional issues
2. Review latency percentiles using KQL queries
3. Check if prompt sizes have increased (more tokens = higher latency)
4. Consider switching to a faster model for latency-sensitive requests

### Key Vault access denied

1. Verify managed identity is assigned:
   ```bash
   az webapp identity show -n myaiproject-dev-app -g rg-myaiproject-dev
   ```
2. Check RBAC assignments:
   ```bash
   az role assignment list --scope <KEY_VAULT_ID> -o table
   ```
3. Verify network rules allow access from App Service subnet

## Routine Operations

### Rotate secrets

1. Generate new secret value
2. Update in Key Vault:
   ```bash
   az keyvault secret set --vault-name myaiproject-dev-kv \
     --name "my-secret" --value "new-value"
   ```
3. Restart App Service to pick up new value (if not using Key Vault references with auto-refresh)

### Scale App Service

Update `sku_name` in the App Service module call:
```hcl
module "app_service" {
  ...
  sku_name = "P1v3"  # was "B1"
}
```
Then run `terraform plan` and `terraform apply`.

### Update model deployment

Modify `model_deployments` in the environment's `main.tf` and apply:
```bash
cd terraform/environments/dev
terraform plan -target=module.ai_foundry
terraform apply -target=module.ai_foundry
```

### View diagnostic logs

```bash
# App Service logs (last 1 hour)
az monitor log-analytics query \
  -w <WORKSPACE_ID> \
  --analytics-query "AppServiceHTTPLogs | where TimeGenerated > ago(1h)" \
  -o table

# AI Services request log
az monitor log-analytics query \
  -w <WORKSPACE_ID> \
  --analytics-query "AzureDiagnostics | where ResourceProvider == 'MICROSOFT.COGNITIVESERVICES' | take 10"
```

## Deployment Procedures

### Standard deployment (dev)

Push to `main` → GitHub Actions auto-deploys.

### Production deployment

1. Create PR with changes
2. Review Terraform plan in PR comments
3. Merge to `main`
4. Trigger manual workflow dispatch for `prod` environment
5. Verify staging slot health
6. Swap slots in Azure Portal or CLI:
   ```bash
   az webapp deployment slot swap \
     -n myaiproject-prod-app \
     -g rg-myaiproject-prod \
     --slot staging \
     --target-slot production
   ```

### Rollback

```bash
# App Service — swap back to previous slot
az webapp deployment slot swap \
  -n myaiproject-prod-app \
  -g rg-myaiproject-prod \
  --slot staging \
  --target-slot production

# Infrastructure — revert to previous Terraform state
git revert <COMMIT_SHA>
git push origin main
```
