# Homelab Infrastructure

Infrastructure as Code (IaC) repository for managing homelab services using Terraform, Docker, and Kubernetes.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Actions                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ push-secrets │→ │deploy-stacks │  │ deploy-cloudflare    │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│         │                 │                     │                │
│         ▼                 ▼                     ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ GitHub       │  │ Portainer    │  │ Cloudflare           │   │
│  │ Secrets      │  │ (Synology)   │  │ (DNS, Access, etc)   │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
homelab/
├── .github/workflows/     # CI/CD pipelines
├── cloudflare/terraform/  # Cloudflare infrastructure (DNS, Access, Tunnels)
├── kubernetes/omni/       # Talos Linux cluster templates managed via Omni
├── portainer/
│   ├── stacks/            # Docker Compose files for each service
│   └── terraform/         # Terraform configs to deploy stacks to Portainer
├── secrets/               # SOPS-encrypted secrets
└── sops/                  # SOPS configuration
```

## Services

### Docker Stacks (Portainer)

| Service | Description |
|---------|-------------|
| **bazarr** | Subtitle management for Sonarr/Radarr |
| **certbot** | SSL certificate management |
| **cloudflared** | Cloudflare Tunnel clients |
| **homeassistant** | Home automation |
| **immich** | Photo/video backup |
| **lidarr** | Music collection manager |
| **netboot** | Network boot server |
| **omni** | Talos Linux cluster management |
| **plex** | Media server |
| **pocketid** | OIDC identity provider |
| **postfix** | Mail relay |
| **prowlarr** | Indexer manager |
| **qbittorrent** | Torrent client |
| **radarr** | Movie collection manager |
| **readarr** | Book collection manager |
| **sonarr** | TV show collection manager |
| **upload-assistant** | Media upload tool |
| **vaultwarden** | Password manager |

### Kubernetes (Omni/Talos)

- **prod** cluster: 3x NUC nodes (control plane + workers)
- Managed via Omni cluster templates
- Cilium CNI, Longhorn storage

## Secrets Management

Secrets are managed using [SOPS](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age) encryption.

```bash
# Encrypt a file
sops -e secrets/reposecrets.sops.yml

# Decrypt a file
sops -d secrets/reposecrets.sops.yml

# Edit encrypted file
sops secrets/reposecrets.sops.yml
```

Secrets are automatically synced to GitHub Secrets when `secrets/reposecrets.sops.yml` is updated.

## CI/CD Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `push-secrets.yml` | Changes to `secrets/` | Decrypts SOPS secrets and pushes to GitHub Secrets |
| `deploy-stacks.yml` | Changes to `portainer/` | Deploys Docker stacks via Terraform |
| `deploy-cloudflare.yml` | Changes to `cloudflare/` | Applies Cloudflare Terraform config |
| `sync-omni-templates.yml` | Changes to `kubernetes/omni/` | Syncs cluster templates to Omni |

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.6
- [SOPS](https://github.com/getsops/sops) >= 3.8
- [age](https://github.com/FiloSottile/age) >= 1.1
- [omnictl](https://docs.siderolabs.com/omni/) (for Kubernetes management)

## Local Development

```bash
# Set up age key for SOPS decryption
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# Cloudflare Terraform
cd cloudflare/terraform
terraform init
terraform plan

# Portainer Terraform
cd portainer/terraform
terraform init
terraform plan
```

## Required GitHub Secrets

See `secrets/reposecrets.sops.yml` for the full list. Key secrets include:

- `SOPS_AGE_KEY` - Age private key for SOPS decryption
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `PORTAINER_API_KEY` - Portainer API key
- `OMNI_ENDPOINT` - Omni instance URL
- `OMNI_SERVICE_ACCOUNT_KEY` - Omni service account key
