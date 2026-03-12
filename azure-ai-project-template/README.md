# Azure AI Project Template

A production-ready template for bootstrapping Azure AI projects on Azure.

## Overview

One `git clone` and you get a working skeleton of a production-grade AI project with best practices baked in.

### What's Included

- **Terraform Modules** — AI Foundry, App Service, Key Vault, networking with Private Endpoints
- **GitHub Actions CI/CD** — Infrastructure + application deployment + security scanning
- **Monitoring** — Alerts, diagnostic settings, log queries
- **Documentation** — Structured docs with architecture decisions and runbooks

### Best Practices Out of the Box

- Multi-environment support (dev / test / prod)
- Secrets managed through Azure Key Vault
- NSG hardening and network isolation
- Non-root containers
- Security scanning with Trivy, Bandit, and Terrascan in the pipeline

## Project Structure

```
azure-ai-project-template/
├── terraform/
│   ├── modules/
│   │   ├── ai-foundry/
│   │   ├── app-service/
│   │   ├── key-vault/
│   │   └── networking/
│   ├── environments/
│   │   ├── dev/
│   │   ├── test/
│   │   └── prod/
│   └── backend.tf
├── .github/
│   └── workflows/
│       ├── infra-deploy.yml
│       ├── app-deploy.yml
│       └── security-scan.yml
├── monitoring/
│   ├── alerts/
│   └── diagnostics/
├── docs/
│   ├── architecture.md
│   ├── setup-guide.md
│   └── runbook.md
└── README.md
```

## Getting Started

### Prerequisites

- Azure subscription
- Terraform >= 1.5
- Azure CLI
- GitHub account (for Actions CI/CD)

### Quick Start

```bash
# Clone the template
git clone https://github.com/yourusername/azure-ai-project-template.git
cd azure-ai-project-template

# Initialize Terraform for dev environment
cd terraform/environments/dev
terraform init
terraform plan
```

## Target Audience

DevOps and Platform Engineers starting an AI project on Azure who don't want to wire everything up from scratch.

## License

MIT
