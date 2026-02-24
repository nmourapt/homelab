# Kubernetes

The core compute platform — a 3-node Talos Linux cluster managed declaratively from bare metal to running applications. This directory contains everything needed to define, bootstrap, and operate the cluster.

## Lifecycle: From Bare Metal to Running Apps

```
 ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
 │  Omni ISO   │────►│ Talos Linux │────►│   Cilium    │────►│   ArgoCD    │
 │  PXE boot   │     │ Cluster via │     │ CNI + LB    │     │ GitOps      │
 │  machines   │     │ template    │     │ via extra   │     │ via extra   │
 │             │     │ sync        │     │ Manifests   │     │ Manifests   │
 └─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                    │
                                                                    ▼
                                                              ┌─────────────┐
                                                              │ Application │
                                                              │ Set scans   │
                                                              │ apps/*      │
                                                              │ auto-deploy │
                                                              └─────────────┘
```

1. **Machines boot the Omni ISO** — Nodes register with the Sidero Omni SaaS and become available for assignment
2. **Cluster template is synced** — `omni/templates/homelab-cluster.yaml` defines the full cluster: Kubernetes/Talos versions, node assignments, network config, storage mounts, and system extensions
3. **Cilium deploys via extraManifests** — Talos applies pre-rendered Cilium manifests from this repo (fetched from GitHub raw URLs) before any pods can schedule, since the default CNI and kube-proxy are disabled
4. **ArgoCD deploys via extraManifests** — Also bootstrapped before anything else exists. The ApplicationSet definition (`apps/_applicationset.yaml`) is applied alongside ArgoCD itself
5. **ArgoCD discovers apps** — The ApplicationSet watches `apps/*/` directories. Every folder with a `kustomization.yaml` becomes an auto-syncing Application. From here, the cluster is self-managing

The entire bootstrap is hands-off after initial machine registration. Pushing a cluster template change to `main` triggers the CI pipeline to sync it to Omni, which rolls it out to the nodes.

## Directory Structure

```
kubernetes/
├── apps/                    # ArgoCD-managed applications
│   ├── _applicationset.yaml # Git directory generator (excluded from app discovery)
│   ├── monitoring/          # kube-prometheus-stack (Helm via Kustomize)
│   ├── traefik/             # Plain Kustomize (Deployment, Service, PVC, IngressRoute)
│   └── ...                  # Each directory = one ArgoCD Application
├── management/              # Kubeconfig, Talosconfig (gitignored)
└── omni/
    └── templates/           # Cluster template, Cilium/ArgoCD manifests, patches
```

## Key Architectural Choices

### Immutable OS

Talos Linux has no SSH, no shell, and no package manager. All configuration is declarative via machine configs. This eliminates drift — every node is identical to what the template describes.

### Bootstrap chicken-and-egg

The cluster needs a CNI before pods can schedule, and ArgoCD before GitOps can begin. Both are solved the same way: Talos `extraManifests` pull raw YAML from this GitHub repo at cluster creation time. This means the bootstrap is self-contained — no external Helm install or manual kubectl step required.

### Self-managing GitOps

ArgoCD manages everything in `apps/`, including its own configuration (`argocd-config/`). The ApplicationSet uses server-side apply and skips dry-run on missing resources to handle CRDs that don't exist until their operator deploys. Sync policy is automated with pruning and self-heal, so manual changes to the cluster are reverted automatically.

### Storage split

Three storage backends for different needs:
- **Longhorn** (NVMe on each node) — Default for application config, replicated for HA
- **Synology CSI** (iSCSI) — Block storage provisioned on the NAS
- **NFS** (Synology) — Shared media mounts for apps that need the same data directory
