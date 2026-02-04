# Omni Cluster Templates

Cluster templates for managing Talos Linux clusters via [Omni](https://docs.siderolabs.com/omni/).

## Clusters

| Template | Description |
|----------|-------------|
| `prod-cluster.yaml` | Production cluster - 3x NUC nodes (control plane + workers) |

## Template Variables

Templates use `${TLD}` placeholder for the domain, which is substituted by the CI/CD pipeline using the `TLD` GitHub secret.

## Prod Cluster Configuration

- **Kubernetes**: v1.34.2
- **Talos**: v1.12.2
- **CNI**: Cilium (Flannel disabled, kube-proxy disabled)
- **Storage**: Longhorn (NVMe drives mounted at `/var/lib/longhorn`)
- **Nodes**: 3x NUCs with VIP at 192.168.202.10
- **Features**: Disk encryption, workload proxy, 12h etcd backups

### System Extensions

- `siderolabs/iscsi-tools` - iSCSI support for Longhorn
- `siderolabs/util-linux-tools` - Utilities for storage management
- `siderolabs/i915` - Intel GPU drivers

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
omnictl cluster template validate -f templates/prod-cluster.yaml

# Sync template (dry-run)
omnictl cluster template sync -f templates/prod-cluster.yaml --dry-run

# Apply template
omnictl cluster template sync -f templates/prod-cluster.yaml

# Export existing cluster to template
omnictl cluster template export -c prod -o exported.yaml
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
