# GitHub Actions Workflows

CI/CD pipelines for deploying homelab infrastructure.

## Workflows

### `push-secrets.yml`

Syncs SOPS-encrypted secrets to GitHub Secrets.

**Triggers:**
- Push to `secrets/reposecrets.sops.yml`
- Manual dispatch

**Flow:**
1. Decrypts `secrets/reposecrets.sops.yml` using age key
2. Iterates through all keys and updates GitHub Secrets
3. Triggers dependent workflows (`deploy-cloudflare`, `deploy-stacks`, `sync-omni-templates`)

---

### `deploy-cloudflare.yml`

Deploys Cloudflare infrastructure via Terraform.

**Triggers:**
- Push to `cloudflare/terraform/*.tf`
- After `push-secrets` workflow completes
- Manual dispatch

**Flow:**
1. Configures R2 credentials for state backend
2. Runs `terraform init`, `plan`, `apply`

---

### `deploy-stacks.yml`

Deploys Docker stacks to Portainer via Terraform.

**Triggers:**
- Push to `portainer/terraform/*.tf`
- Push to `portainer/stacks/**/*.yml` or `*.env`
- After `push-secrets` workflow completes
- Manual dispatch (optionally specify single service)

**Flow:**
1. Detects which services changed
2. Decrypts SOPS environment files
3. Substitutes variables in docker-compose files
4. Runs Terraform for each changed service
5. Handles service deletion when `.tf` files are removed

---

### `sync-omni-templates.yml`

Syncs Omni cluster templates for Talos Linux clusters.

**Triggers:**
- Push to `kubernetes/omni/templates/**`
- Pull request to `main` (validation only)
- Manual dispatch (with optional dry-run)

**Flow:**
1. Detects changed template files
2. Substitutes `${TLD}` placeholder with secret value
3. Validates templates with `omnictl cluster template validate`
4. Syncs to Omni with `omnictl cluster template sync`

## Required Secrets

| Secret | Used By | Description |
|--------|---------|-------------|
| `SOPS_AGE_KEY` | All | Age private key for SOPS decryption |
| `FINE_GRAINED_TOKEN` | push-secrets | GitHub token for updating secrets |
| `CLOUDFLARE_API_TOKEN` | deploy-cloudflare | Cloudflare API token |
| `CF_ACCOUNT_ID` | deploy-cloudflare | Cloudflare account ID |
| `CF_TLD_ZONE_ID` | deploy-cloudflare | Zone ID for primary domain |
| `TLD` | deploy-cloudflare, sync-omni | Primary domain |
| `PORTAINER_API_KEY` | deploy-stacks | Portainer API key |
| `R2_TF_*_ACCESS_KEY_ID` | All Terraform | R2 state backend credentials |
| `R2_TF_*_SECRET_ACCESS_KEY` | All Terraform | R2 state backend credentials |
| `OMNI_ENDPOINT` | sync-omni | Omni instance URL |
| `OMNI_SERVICE_ACCOUNT_KEY` | sync-omni | Omni service account key |

## Manual Dispatch

All workflows support manual dispatch via GitHub UI or CLI:

```bash
# Deploy specific Portainer service
gh workflow run deploy-stacks.yml -f service=plex

# Sync Omni templates (dry-run)
gh workflow run sync-omni-templates.yml -f dry_run=true

# Re-deploy Cloudflare config
gh workflow run deploy-cloudflare.yml
```
