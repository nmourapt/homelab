# Homelab

Full-stack homelab infrastructure managed entirely as code. Combines a 3-node Kubernetes cluster, a Synology NAS running Docker workloads, and Cloudflare for networking and security — all glued together with GitOps, Terraform, and CI/CD pipelines.

This isn't a tutorial or a deployment guide. It's a living, production-like environment that I use daily and iterate on constantly.

## Architecture

```
                          ┌──────────────────────┐
                          │    Cloudflare Edge    │
                          │  DNS, Tunnels, Zero   │
                          │  Trust Access, WAF    │
                          └──────────┬───────────┘
                                     │
                     ┌───────────────┼───────────────┐
                     ▼                               ▼
          ┌─────────────────┐             ┌─────────────────┐
          │  Kubernetes      │             │  Synology NAS    │
          │  3x Intel NUC    │◄── NFS ───►│  Docker/Portainer│
          │  Talos Linux     │   iSCSI    │  PostgreSQL DBs  │
          │  Cilium + Traefik│             │  Media Storage   │
          └────────┬────────┘             └────────┬────────┘
                   │                                │
                   └────────────────────────────────┘
                                     │
                          ┌──────────┴───────────┐
                          │    GitHub Actions     │
                          │  CI/CD Pipelines      │
                          │  SOPS Secret Sync     │
                          └──────────────────────┘
```

The environment runs on a single VLAN (`192.168.202.0/24`) with three Intel N100 NUCs forming the Kubernetes cluster and a Synology DS923+ handling persistent storage, databases, and some Docker workloads.

## Key Design Decisions

### Why two compute platforms?

Not everything belongs in Kubernetes. Stateful services that benefit from direct disk access (Plex, qBittorrent, Immich server) run on the Synology via Docker/Portainer. Stateless or easily-replicated services (reverse proxies, monitoring, *arr stack UIs, GitOps tooling) run on Kubernetes. The NAS provides NFS and iSCSI storage to both.

### Zero exposed ports

No ports are forwarded from the router. All external access flows through **Cloudflare Tunnels** — three of them, each serving a different role:
- **lis_k8s** — Routes to Kubernetes services via Traefik (wildcard `*.domain`)
- **lis_prod** — Routes to NAS-hosted services (Vaultwarden, PocketID, Home Assistant)
- **lis_isp** — Routes to ISP-side network gear (Omada controller on a separate subnet)

### Identity and access control

Every externally-exposed service sits behind **Cloudflare Zero Trust Access**. Authentication goes through a self-hosted **PocketID** (OIDC provider), with geo-fenced policies: 8-hour sessions from Portugal, 15-minute sessions from anywhere else. Some services (like Autobrr) use Cloudflare Access SaaS OIDC for SSO directly into the app.

### GitOps everywhere

- **Kubernetes** — ArgoCD with an ApplicationSet that auto-discovers any directory under `kubernetes/apps/`. Drop a folder, push, and it's deployed.
- **Docker stacks** — Terraform applies Docker Compose files to Portainer via API. GitHub Actions triggers on file changes.
- **Cloudflare** — Terraform manages DNS records, tunnels, Access apps, Access policies, Spectrum apps, and redirect rules. State stored in R2.
- **Cluster config** — Talos Linux cluster templates synced to Omni via `omnictl` in CI.

### Secrets at rest

Two layers:
- **SOPS + age** for CI/CD secrets (Terraform variables, API keys). Encrypted in Git, decrypted in GitHub Actions, pushed to GitHub Secrets.
- **Sealed Secrets** for Kubernetes. Plaintext `.secret.yaml` files are gitignored; only the encrypted `.sealedsecret.yaml` files are committed.

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **OS** | Talos Linux | Immutable, API-driven Kubernetes OS |
| **Cluster Management** | Sidero Omni | Declarative cluster lifecycle via templates |
| **CNI** | Cilium | Networking with kube-proxy replacement, L2 announcements for LoadBalancer IPs |
| **Ingress** | Traefik | Reverse proxy with automatic TLS via cert-manager |
| **TLS** | cert-manager | Let's Encrypt certificates with Cloudflare DNS-01 challenge |
| **DNS** | external-dns | Auto-creates Cloudflare DNS records from IngressRoute annotations |
| **GitOps** | ArgoCD | Continuous deployment with auto-sync, prune, and self-heal |
| **Storage** | Longhorn | Distributed block storage across NVMe drives on each node |
| **Storage** | Synology CSI | iSCSI volumes provisioned directly on the NAS |
| **Storage** | NFS | Shared media/data mounts from Synology |
| **Monitoring** | Prometheus + Grafana | Full-stack observability with custom dashboards and per-service Traefik metrics |
| **Alerting** | Alertmanager | Telegram notifications for cluster, node, storage, and application alerts |
| **Logging** | Elastic Stack (ECK) | Elasticsearch + Kibana + Fleet Server with Cloudflare Logpush via R2 |
| **GPU** | Intel GPU Device Plugin | iGPU passthrough for hardware-accelerated ML inference (Immich) |
| **Secrets** | Sealed Secrets + SOPS | Encrypted secrets in Git for both Kubernetes and CI/CD |
| **IaC** | Terraform | Manages Cloudflare, Portainer stacks, and state in R2 |
| **CI/CD** | GitHub Actions | Four workflows covering secrets, stacks, Cloudflare, and cluster templates |

## Repository Structure

```
homelab/
├── .github/workflows/        # CI/CD pipelines (4 workflows)
├── cloudflare/terraform/     # Tunnels, DNS, Zero Trust Access, Spectrum
├── kubernetes/
│   ├── apps/                 # 27 ArgoCD-managed applications
│   ├── management/           # Kubeconfig, Talosconfig (gitignored)
│   └── omni/templates/       # Talos cluster templates + Cilium/ArgoCD manifests
├── portainer/
│   ├── stacks/               # 23 Docker Compose definitions
│   └── terraform/            # Stack deployment automation
├── secrets/                  # SOPS-encrypted secret store
└── synology/                 # NAS bootstrap automation
```

Each subdirectory has its own README with detailed architectural context.

## Kubernetes Applications

The cluster runs 27 applications, each in its own namespace, auto-discovered by ArgoCD:

| Category | Applications |
|----------|-------------|
| **Platform** | ArgoCD config, cert-manager, sealed-secrets, external-dns, cloudflared, Traefik |
| **Storage** | Longhorn, Synology CSI, Intel GPU device plugin |
| **Monitoring** | Prometheus, Grafana, Alertmanager (kube-prometheus-stack), ECK Operator, Elasticsearch, Kibana, Fleet Server, Hubble |
| **Media Management** | Sonarr, Radarr, Prowlarr, Bazarr, Seerr |
| **Download Tools** | Cross-seed, qbitmanage, Autobrr, FlareSolverr, Profilarr |
| **Other** | Immich ML (OpenVINO), The Lounge (IRC), Apprise (notifications) |

## Docker Stacks (Synology NAS)

23 services managed via Portainer + Terraform, including:

| Category | Services |
|----------|---------|
| **Media** | Plex, qBittorrent, Immich server |
| **Identity** | PocketID (OIDC), Vaultwarden |
| **Infrastructure** | Cloudflare Tunnels (2x), Certbot, Postfix, Netboot, Omni |
| **Databases** | PostgreSQL instances for Sonarr, Radarr, Prowlarr, Bazarr, Lidarr, Readarr, Seerr, Autobrr |
| **Home** | Home Assistant |

## Monitoring and Alerting

Full observability stack with Prometheus scraping all services, custom Grafana dashboards (including per-service Traefik metrics), and Alertmanager routing warnings and critical alerts to Telegram. 13+ alert groups covering nodes, pods, storage, ArgoCD sync status, Longhorn health, Traefik error rates, and Synology CSI.

Cloudflare logs (14 data streams including HTTP requests, DNS, firewall events, and Gateway traffic) are pushed to R2 and ingested into Elasticsearch via Fleet Server for centralized analysis in Kibana.

## Networking

All traffic enters through Cloudflare — no open ports on the home network. Cloudflare Spectrum proxies TCP services (squid proxy, email relay) for cases where HTTP tunnels aren't suitable. Inside the cluster, Cilium handles pod networking with VXLAN tunnels and provides LoadBalancer IPs via L2 announcements from a dedicated pool (`192.168.202.101-199`).
