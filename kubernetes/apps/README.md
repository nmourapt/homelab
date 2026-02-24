# Kubernetes Applications

27 applications deployed to a 3-node Talos Linux cluster, fully managed by ArgoCD with zero manual intervention after `git push`.

## GitOps Model

An [ApplicationSet](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/) with a Git directory generator watches `kubernetes/apps/`. Every subdirectory (except `_`-prefixed ones) automatically becomes an ArgoCD Application with:

- **Namespace** matching the directory name
- **Automated sync** with pruning and self-heal
- **Server-side apply** to handle large CRDs (e.g., Prometheus Operator)
- **Kustomize + Helm** support — most apps use Kustomize, some wrap Helm charts

Adding a new service is just creating a directory with a `kustomization.yaml` and pushing. ArgoCD handles the rest.

## Application Patterns

Apps in this cluster follow two main patterns:

**Plain Kustomize** — Most apps (Sonarr, Radarr, Autobrr, etc.) use raw manifests: a Namespace, Deployment, Service, PVC, ConfigMap, SealedSecret, and IngressRoute. The NAS provides shared storage via NFS PV/PVCs, and each app gets its own Longhorn PVC for config persistence.

**Kustomize + Helm** — Platform components (Traefik, cert-manager, Longhorn, kube-prometheus-stack, Sealed Secrets, ECK) are deployed as Helm charts rendered through Kustomize, with value overrides and patches applied declaratively.

## Applications

### Platform

| App | Role |
|-----|------|
| **Traefik** | Ingress controller with automatic TLS, per-service Prometheus metrics |
| **cert-manager** | TLS certificates via Let's Encrypt (Cloudflare DNS-01 challenge) |
| **external-dns** | Auto-creates Cloudflare DNS records from IngressRoute annotations |
| **cloudflared** | Cloudflare Tunnel connector — the only path for external traffic into the cluster |
| **sealed-secrets** | Decrypts SealedSecrets into native K8s Secrets at runtime |
| **argocd-config** | Additional ArgoCD configuration (AppProject, RBAC) |

### Storage and Compute

| App | Role |
|-----|------|
| **longhorn-system** | Distributed block storage across NVMe drives on each node (3-replica and single-replica StorageClasses) |
| **synology-csi** | iSCSI volume provisioner for Synology NAS (using a Talos-compatible fork with nsenter instead of chroot) |
| **intel-gpu** | Intel GPU device plugin — exposes i915 iGPU on each N100 node for hardware-accelerated workloads |

### Monitoring and Observability

| App | Role |
|-----|------|
| **monitoring** | kube-prometheus-stack (Prometheus, Grafana, Alertmanager) with custom dashboards and 13+ alert groups routed to Telegram |
| **eck-operator** | Elastic Cloud on Kubernetes operator |
| **elastic-system** | Elasticsearch + Kibana + Fleet Server — ingests 14 Cloudflare log streams from R2 |
| **hubble** | Cilium network observability UI |
| **flaresolverr** | Cloudflare challenge solver with custom Prometheus exporter and Grafana dashboard |

### Media Management

| App | Role |
|-----|------|
| **sonarr** | TV show management — PostgreSQL on NAS, NFS media storage |
| **radarr** | Movie management — same pattern as Sonarr |
| **prowlarr** | Indexer management — feeds Sonarr/Radarr |
| **bazarr** | Subtitle management |
| **seerr** | Media request portal |

### Download Automation

| App | Role |
|-----|------|
| **autobrr** | IRC announce monitoring and automated downloads (custom image with qBitrace, OIDC via Cloudflare Access SaaS) |
| **cross-seed** | Cross-seeding daemon — matches existing media across trackers |
| **qbitmanage** | qBittorrent management — tagging, share limits, orphan cleanup, with Telegram notifications via Apprise |
| **profilarr** | Quality profile sync across Sonarr/Radarr instances |

### Other

| App | Role |
|-----|------|
| **immich-ml** | Immich machine learning backend with OpenVINO on Intel iGPU, exposed via externalIP to NAS-hosted Immich server |
| **thelounge** | Self-hosted IRC client |
| **apprise** | Internal notification gateway — receives webhooks from apps and forwards to Telegram |

## Storage Architecture

Three storage backends coexist:

- **Longhorn** — Default for app config PVCs. Replicated across nodes for HA, with a single-replica class for large/non-critical volumes (Elasticsearch, Grafana).
- **Synology CSI (iSCSI)** — For workloads that need raw block storage on the NAS.
- **NFS** — Shared `/volume1/data` mount for media files. Each app that needs access to torrents/media gets a dedicated NFS PV/PVC pair bound to the same export.

## Secrets

Plaintext `.secret.yaml` files are gitignored. Only `.sealedsecret.yaml` files (encrypted by `kubeseal` against the in-cluster Sealed Secrets controller) are committed. Some apps use an initContainer pattern to inject secret values into config files at startup via `sed` substitution of `${PLACEHOLDER}` tokens.
