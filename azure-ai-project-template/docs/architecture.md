# Architecture

## Overview

This template deploys a secure, production-ready Azure AI application stack with network isolation, centralized secrets management, and observability.

## Components

### Networking

- **VNet** with dedicated subnets for App Service, Private Endpoints, and AI Foundry
- **NSGs** with deny-all default and explicit allow rules
- **Private DNS Zones** for Key Vault, App Service, Cognitive Services, and OpenAI
- All PaaS services connected via **Private Endpoints** — no public internet exposure in production

### Compute

- **Azure App Service (Linux)** running containerized Python/FastAPI application
- VNet-integrated for secure outbound traffic to private endpoints
- Staging slot enabled in production for blue-green deployments
- Health check endpoint configured

### AI Services

- **Azure AI Services** account with model deployments (GPT-4o by default)
- **AI Foundry Hub + Project** for centralized AI resource management
- Public access disabled in production
- Request/response logging enabled for audit

### Security

- **Azure Key Vault** with RBAC authorization (no access policies)
- Purge protection enabled in production
- Network ACLs set to deny by default
- All secrets referenced via Key Vault URI in app settings
- Managed Identity used for service-to-service authentication

### Monitoring

- **Log Analytics Workspace** collects logs from all resources
- Diagnostic settings enabled on App Service, Key Vault, and AI Services
- Metric alerts for response time, 5xx errors, AI latency, and availability
- KQL queries provided for token usage, error rates, and latency percentiles

## Network Flow

```
Internet
  │
  ▼
App Service (VNet-integrated)
  │
  ├──► Private Endpoint ──► Key Vault
  │
  └──► Private Endpoint ──► AI Services (OpenAI models)
```

## Environment Strategy

| Aspect | Dev | Test | Prod |
|---|---|---|---|
| App Service SKU | B1 | S1 | P1v3+ |
| Public access | Allowed | Restricted | Denied |
| Key Vault purge protection | Disabled | Disabled | Enabled |
| Staging slot | No | No | Yes |
| Log retention | 30 days | 30 days | 90+ days |
| Storage replication | LRS | LRS | GRS |

## Security Principles

1. **Zero Trust Networking** — All services communicate through private endpoints
2. **Least Privilege** — Managed identities with RBAC, no shared keys
3. **Defense in Depth** — NSGs + Private Endpoints + Key Vault network ACLs
4. **Shift Left Security** — Trivy, Bandit, and Terrascan run in CI before deployment
5. **Non-root Containers** — Application runs as unprivileged user
