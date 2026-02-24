# Portainer Stacks

Docker Compose stacks running on a Synology 918+ NAS, deployed and managed through Terraform against the Portainer API. This is the compute layer for stateful, storage-heavy, or latency-sensitive services that don't benefit from Kubernetes orchestration.

## Why Portainer + Terraform

Portainer provides a Docker management UI on the NAS, but stacks are never created manually through it. Instead, each service has a Terraform resource that points to its Docker Compose file. GitHub Actions detects which stacks changed on push and applies only the affected ones — so the deployment model mirrors the Kubernetes GitOps approach, just with Terraform instead of ArgoCD.

## Services

| Category | Stacks |
|----------|--------|
| **Media** | Plex |
| **Photos** | Immich (server + microservices + Redis + ML on K8s) |
| **Identity** | PocketID (self-hosted OIDC provider), Vaultwarden (password manager) |
| **Networking** | Cloudflare Tunnels (2x: prod + ISP), Traefik (NAS-side reverse proxy) |
| **Infrastructure** | Certbot, Postfix (mail relay), Netboot, Omni (Talos cluster management) |
| **Home** | Home Assistant |
| **Databases** | PostgreSQL instances |

### Database pattern

Each *arr application that runs on Kubernetes has its corresponding PostgreSQL database running on the NAS as a dedicated single-container stack. This keeps databases on reliable NAS storage with BTRFS snapshots, while the app frontends run in the cluster.

## Secrets

Environment variables containing credentials are stored in SOPS-encrypted `.env` files alongside each stack's `docker-compose.yml`. The CI pipeline decrypts them at deploy time and substitutes `${VAR}` placeholders in the compose files before pushing to Portainer.

## Structure

```
portainer/
├── stacks/<service>/
│   ├── docker-compose.yml      # Service definition
│   └── <service>.env           # SOPS-encrypted environment variables (optional)
└── terraform/
    ├── <service>.tf            # Portainer stack resource (one per service)
    ├── network.tf              # Shared Docker networks
    ├── provider.tf             # Portainer provider config
    └── backend.tf              # R2 state backend
```

State is stored in Cloudflare R2, same as the Cloudflare Terraform configuration.
