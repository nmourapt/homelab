# Homelab

Full-stack homelab infrastructure managed entirely as code. Combines a 3-node Kubernetes cluster, a Synology NAS running Docker workloads, and Cloudflare for networking and security — all glued together with GitOps, Terraform, and CI/CD pipelines.

This isn't a tutorial or a deployment guide. It's a living, production-like environment that I use daily and iterate on constantly.

A human review is done before significant changes get pushed (unless Windsurf goes rogue and decides to ignore instructions), but Claude is used for a significant part of the state generation process. Being able to generate barebones YAML files from two input lines only then requiring small adjustments and review speeds things up considerably.

## Architecture

```
                        ┌──────────────────────┐
                        │    Cloudflare Edge   │
                        │  DNS, Tunnels, Zero  │
                        │  Trust Access, WAF   │
                        └──────────┬───────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
   ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
   │  Kubernetes      │ │  Synology NAS    │ │  OCI (Oracle)    │
   │  3x Intel NUC    │ │  Docker/Portainer│ │  ARM A1.Flex     │
   │  Talos Linux     │ │  PostgreSQL DBs  │ │  OpenClaw        │
   │  Cilium + Traefik│ │  Media Storage   │ │  Cloudflare Tun. │
   └────────┬─────────┘ └────────┬─────────┘ └──────────────────┘
            │         NFS/iSCSI  │
            └────────────────────┘
                        │
             ┌──────────┴───────────┐
             │    GitHub Actions    │
             │  CI/CD Pipelines     │
             │  SOPS Secret Sync    │
             └──────────────────────┘
```

The local environment runs on a single VLAN (`192.168.202.0/24`) with three Intel N100 NUCs forming the Kubernetes cluster and a Synology DS918+ handling persistent storage, databases, and some Docker workloads. An OCI Always Free ARM instance (Ampere A1.Flex) in Frankfurt runs OpenClaw, accessed exclusively through a Cloudflare Tunnel.

## Key Design Decisions

### Why two compute platforms?

Not everything belongs in Kubernetes. Stateful services that benefit from direct disk access (Plex, Immich) or need to be more robust (i.e. won't be subject to me deciding to tear down and rebuild the cluster) (Vaultwarden, PocketID) run on the Synology via Docker/Portainer. Stateless or easily-replicated services (reverse proxies, monitoring, *arr stack UIs, GitOps tooling) run on Kubernetes. The NAS provides NFS and iSCSI storage to both.

### Zero exposed ports

No ports are forwarded from the router. All external access flows through **Cloudflare Tunnels** — four of them, each serving a different role:
- **lis_k8s** — Routes to Kubernetes services via Traefik (with external-dns creating the necessary records)
- **lis_prod** — Routes to NAS-hosted services via its' own Traefik (using traefik-cloudflare-companion for DNS)
- **lis_isp** — Routes to a different, isolated VLAN (ISP)
- **oci_claw** — Routes to the OCI instance (SSH + OpenClaw)

### Identity and access control

Every externally-exposed service sits behind **Cloudflare Zero Trust Access**. Authentication goes through a self-hosted **PocketID** (OIDC provider), with geo-fenced policies: 8-hour sessions from Portugal, 15-minute sessions from anywhere else. Some services (like Immich) use Cloudflare Access OIDC for SSO directly into the app. Additionally, Google can be used as the SSO provider for some tools which are shared with external users.

### GitOps everywhere

- **Kubernetes** — ArgoCD with an ApplicationSet that auto-discovers any directory under `kubernetes/apps/`. Drop a folder, push, and it's deployed.
- **Docker stacks** — Terraform applies Docker Compose files to Portainer via API. GitHub Actions triggers on file changes.
- **Cloudflare** — Terraform manages DNS records, tunnels, Access apps, Access policies, Spectrum apps, and redirect rules. State stored in R2.
- **OCI** — Terraform provisions the Oracle Cloud instance, networking, and cloud-init. State stored in R2.
- **Cluster config** — Talos Linux cluster templates synced to Omni via `omnictl` in CI.

### Secrets at rest

Two layers:
- **SOPS + age** for CI/CD secrets (Terraform variables, API keys). Encrypted in Git, decrypted in GitHub Actions, pushed to GitHub Secrets.
- **Sealed Secrets** for Kubernetes. 

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
| **IaC** | Terraform | Manages Cloudflare, Portainer stacks, OCI infrastructure, and state in R2 |
| **CI/CD** | GitHub Actions | Five workflows covering secrets, stacks, Cloudflare, OCI, and cluster templates |
| **Dependency Management** | Renovate | Automated PRs for container images, Helm charts, Terraform providers, and Docker Compose images |

## Dependency Management

[Renovate](https://docs.renovatebot.com/) continuously scans the repo for outdated dependencies across all layers — Kubernetes manifests (container image tags), Kustomize Helm charts (version fields), Docker Compose images, and Terraform providers. Minor and patch updates are automerged during non-office hours; major version bumps open PRs for manual review.

## Repository Structure

```
homelab/
├── .github/workflows/        # CI/CD pipelines (5 workflows)
├── cloudflare/terraform/     # Tunnels, DNS, Zero Trust Access, Spectrum
├── kubernetes/
│   ├── apps/                 # ArgoCD-managed applications
│   ├── management/           # Kubeconfig, Talosconfig (gitignored)
│   └── omni/templates/       # Talos cluster templates + Cilium/ArgoCD manifests
├── openclaw/terraform/       # OCI instance, networking, cloud-init
├── portainer/
│   ├── stacks/               # Docker Compose definitions
│   └── terraform/            # Stack deployment automation
├── secrets/                  # SOPS-encrypted secret store
└── synology/                 # NAS bootstrap automation (Ansible - currently gitignored, due for cleanup)
```

Each subdirectory has its own README with detailed architectural context.

## Kubernetes Applications

The cluster runs several applications, each in its own namespace, auto-discovered by ArgoCD:

| Category | Applications |
|----------|-------------|
| **Platform** | ArgoCD config, cert-manager, sealed-secrets, external-dns, cloudflared, Traefik |
| **Storage** | Longhorn, Synology CSI, Intel GPU device plugin |
| **Monitoring** | Prometheus, Grafana, Alertmanager (kube-prometheus-stack), ECK Operator, Elasticsearch, Kibana, Fleet Server, Hubble |
| **Media Management** | *arr Stack |
| **Other** | Immich ML (OpenVINO), The Lounge (IRC), Apprise (notifications) |

## Docker Stacks (Synology NAS)

Multiple services managed via Portainer + Terraform, including:

| Category | Services |
|----------|---------|
| **Media** | Plex, Immich server |
| **Identity** | PocketID (OIDC), Vaultwarden |
| **Infrastructure** | Cloudflare Tunnels (2x), Certbot, Postfix, Netboot, Omni |
| **Databases** | Various PostgreSQL instances |
| **Home** | Home Assistant |

## Monitoring and Alerting

Full observability stack with Prometheus scraping all services, custom Grafana dashboards (including per-service Traefik metrics), and Alertmanager routing warnings and critical alerts to Telegram. Key alert groups including nodes, pods, storage, ArgoCD sync status, Longhorn health, Traefik error rates, and Synology CSI.

Cloudflare logs (data streams including HTTP requests, DNS, firewall events, and Gateway traffic) are pushed to R2 and ingested into Elasticsearch via Fleet Server for centralized analysis in Kibana.

## Networking

All traffic enters through Cloudflare — no open ports on the home network. Cloudflare Spectrum proxies TCP services (email relay) for cases where HTTP tunnels aren't suitable. Inside the cluster, Cilium handles pod networking with VXLAN tunnels and provides LoadBalancer IPs via L2 announcements from a dedicated pool (`192.168.202.101-199`). The OCI instance in Frankfurt is connected via its own Cloudflare Tunnel with no public IP or open ingress.
