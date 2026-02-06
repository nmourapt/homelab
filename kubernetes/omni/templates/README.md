# Omni Cluster Templates

Cluster templates for managing Talos Linux clusters via [Omni](https://docs.siderolabs.com/omni/).

## Directory Structure

```
templates/
├── homelab-cluster.yaml      # Main cluster template
├── patches/
│   └── extraManifests.yaml   # Patch to install Cilium via extraManifests
└── manifests/
    ├── cilium-helm/
    │   └── values.yaml       # Helm values used to generate Cilium manifests
    ├── cilium_manifests.yaml # Pre-rendered Cilium Helm chart manifests
    ├── l2_announcements.yaml # CiliumL2AnnouncementPolicy for LB IPs
    └── ip_pool.yaml          # CiliumLoadBalancerIPPool (192.168.202.101-199)
```

## Clusters

| Template | Description |
|----------|-------------|
| `homelab-cluster.yaml` | Homelab cluster - 1x NUC node (control plane with scheduling enabled) |

## Template Variables

Templates use `${TLD}` placeholder for the domain, which is substituted by the CI/CD pipeline using the `TLD` GitHub secret.

## Homelab Cluster Configuration

- **Kubernetes**: v1.34.2
- **Talos**: v1.12.2
- **CNI**: Cilium (native CNI disabled, kube-proxy disabled)
- **Storage**: Longhorn (NVMe drives mounted at `/var/lib/longhorn`)
- **Nodes**: 1x NUC with VIP at 192.168.202.10
- **Features**: 12h etcd backups, scheduling on control plane enabled

### System Extensions

- `siderolabs/iscsi-tools` - iSCSI support for Longhorn
- `siderolabs/util-linux-tools` - Utilities for storage management
- `siderolabs/i915` - Intel GPU drivers

### Cilium Configuration

Cilium is deployed via `extraManifests` using pre-rendered Helm chart manifests. Key features:

- **kube-proxy replacement**: Enabled
- **IPAM**: Kubernetes mode
- **L2 Announcements**: Enabled for LoadBalancer IPs
- **External IPs**: Enabled
- **LoadBalancer IP Pool**: 192.168.202.101-199

To regenerate Cilium manifests after modifying `cilium-helm/values.yaml`:

```bash
helm template cilium cilium/cilium \
  --namespace kube-system \
  --values manifests/cilium-helm/values.yaml \
  > manifests/cilium_manifests.yaml
```

## Usage

### Prerequisites

1. Install `omnictl` CLI (download from your Omni instance)
2. Authenticate with Omni
3. Register machines by booting with Omni ISO

### Manual Operations

```bash
# List clusters
omnictl get clusters

# List machines
omnictl get machines

# Validate template
omnictl cluster template validate -f templates/homelab-cluster.yaml

# Sync template (dry-run)
omnictl cluster template sync -f templates/homelab-cluster.yaml --dry-run

# Apply template
omnictl cluster template sync -f templates/homelab-cluster.yaml

# Export existing cluster to template
omnictl cluster template export -c homelab -o exported.yaml
```

### GitOps Workflow

Templates are automatically synced when changes are pushed to `main`. The workflow:

1. Substitutes `${TLD}` with the actual domain
2. Validates templates with `omnictl cluster template validate`
3. Syncs to Omni with `omnictl cluster template sync`

See `.github/workflows/sync-omni-templates.yml`.

## Adding New Machines

1. Boot the machine with the Omni ISO
2. Find the machine UUID: `omnictl get machines`
3. Update the template with the actual UUID
4. Push changes to trigger sync

## Reference

- [Omni Cluster Templates](https://docs.siderolabs.com/omni/reference/cluster-templates)
- [omnictl CLI](https://docs.siderolabs.com/omni/reference/cli)
