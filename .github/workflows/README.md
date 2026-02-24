# CI/CD Pipelines

Four GitHub Actions workflows that together ensure every part of the infrastructure is deployed automatically on push. No manual `terraform apply`, no `kubectl apply`, no SSH.

## Pipeline Architecture

```
                    ┌─────────────────┐
                    │  push-secrets   │  Decrypts SOPS → pushes to GitHub Secrets
                    └────────┬────────┘
                             │ triggers
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
   ┌──────────────┐ ┌──────────────────┐ ┌───────────────────┐
   │deploy-stacks │ │deploy-cloudflare │ │sync-omni-templates│
   │  (Portainer) │ │   (Terraform)    │ │      (Talos)      │
   └──────────────┘ └──────────────────┘ └───────────────────┘
```

Secrets flow is the backbone: when SOPS-encrypted secrets change, `push-secrets` decrypts them and updates GitHub Secrets, then triggers all three downstream workflows to pick up the new values.

## Workflows

### push-secrets

The secret distribution layer. Decrypts `secrets/reposecrets.sops.yml` (age-encrypted) and pushes each key-value pair to GitHub Secrets. Then cascades to all other workflows so they always use current credentials.

### deploy-cloudflare

Runs `terraform apply` against Cloudflare for DNS, tunnels, Access apps, Spectrum, and all other Cloudflare resources. Triggers on changes to `cloudflare/terraform/*.tf` or after secrets are updated. State lives in Cloudflare R2.

### deploy-stacks

The most complex pipeline. Detects which Portainer stacks changed (by diffing Terraform files and Compose files), decrypts SOPS `.env` files, substitutes variables into Compose definitions, and runs Terraform per-service. Includes:

- **Selective deployment** — Only changed stacks are applied, not the entire fleet
- **Stack deletion handling** — Detects removed `.tf` files and destroys the corresponding stacks
- **Retry logic** — 3 attempts with 30s delay to handle Synology Docker daemon rate limits
- **Manual targeting** — Can deploy a single service by name via workflow dispatch

### sync-omni-templates

Syncs Talos Linux cluster templates to Sidero Omni. Substitutes `${TLD}` placeholders with the actual domain, validates templates with `omnictl`, and syncs. On pull requests, runs validation only (dry-run) as a gate.

## Design Choices

- **All workflows support manual dispatch** — Any workflow can be re-run from the GitHub UI or CLI, useful for recovery or one-off deploys
- **Path-filtered triggers** — Each workflow only runs when its relevant files change, avoiding unnecessary deploys
- **Cascading from secrets** — A single secrets update propagates to all infrastructure layers automatically
- **Terraform state in R2** — Both Cloudflare and Portainer Terraform configs store state in Cloudflare R2, keeping it cheap and close to the Cloudflare API
