# Cluster Templates

Declarative configuration for the Kubernetes cluster, managed through [Sidero Omni](https://docs.siderolabs.com/omni/). A single cluster template defines the entire cluster — nodes, networking, storage mounts, CNI, and the GitOps bootstrap — and is synced to Omni automatically via CI/CD.

## Why Talos + Omni

Talos Linux is an immutable, API-only Kubernetes OS with no SSH, no shell, and no package manager. Combined with Omni for lifecycle management, the cluster can be fully reproduced from this template alone — there's no configuration drift, no snowflake nodes, and upgrades are a version bump in YAML.

## Cluster Topology

Three Intel N100 NUCs, all running as control plane nodes with scheduling enabled (no dedicated workers). Each node has:

- **Boot disk** — `/dev/sda` (eMMC/SSD) for Talos OS
- **NVMe drive** — `/dev/nvme0n1` partitioned and mounted at `/var/lib/longhorn` for distributed storage
- **Static IP** — `192.168.202.11-13` with a shared VIP at `192.168.202.10`
- **System extensions** — iSCSI tools (Longhorn/Synology CSI), util-linux (storage management), i915 (Intel GPU drivers)

Etcd backups run every 12 hours.

## Bootstrapping

Two critical components are deployed as Talos `extraManifests` (applied before ArgoCD exists):

### Cilium

Pre-rendered Helm manifests deployed at cluster bootstrap. This is necessary because Talos disables the default CNI and kube-proxy — pods can't schedule until Cilium is running.

Key configuration choices:
- **kube-proxy replacement** — Cilium handles all service routing (eBPF-based, lower latency)
- **VXLAN tunneling** — Overlay networking to avoid L2 adjacency requirements
- **MTU 1450** — Explicitly set to avoid Siderolink MTU detection issues during Omni management
- **L2 Announcements** — Cilium responds to ARP requests for LoadBalancer IPs, eliminating the need for MetalLB
- **IP Pool** — `192.168.202.101-199` reserved for LoadBalancer services

### ArgoCD

Also deployed via `extraManifests` so GitOps is available from first boot. Once running, ArgoCD takes over and manages everything else (including its own configuration via `argocd-config/`). Kustomize Helm rendering is enabled so apps can use Helm charts without Tiller.

## Template Structure

```
templates/
├── homelab-cluster.yaml        # Cluster definition: nodes, patches, versions
├── patches/
│   ├── ciliumPatch.yaml        # extraManifests patch for Cilium
│   └── argoPatch.yaml          # extraManifests patch for ArgoCD
└── manifests/
    ├── cilium-helm/values.yaml # Helm values used to generate Cilium manifests
    ├── cilium_manifests.yaml   # Pre-rendered Cilium Helm output
    ├── argo_manifests.yaml     # ArgoCD installation manifests
    ├── l2_announcements.yaml   # CiliumL2AnnouncementPolicy
    └── ip_pool.yaml            # CiliumLoadBalancerIPPool
```

The `${TLD}` placeholder in the cluster template is substituted by the CI/CD pipeline with the actual domain before syncing to Omni.
