# Kubernetes Applications

ArgoCD-managed applications deployed to the homelab Kubernetes cluster.

## Architecture

Applications are automatically discovered and deployed by ArgoCD using an [ApplicationSet](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/) with a Git directory generator.

```
kubernetes/apps/
├── _applicationset.yaml    # ApplicationSet definition (excluded from app discovery)
├── sealed-secrets/         # Sealed Secrets controller
└── cloudflared/            # Cloudflare Tunnel connector
```

## How It Works

1. The `_applicationset.yaml` watches `kubernetes/apps/*` for directories
2. Directories starting with `_` are excluded
3. Each directory becomes an ArgoCD Application with:
   - **Name**: Directory basename (e.g., `cloudflared`)
   - **Namespace**: Same as app name
   - **Source**: The directory path (supports Kustomize or Helm)
   - **Sync Policy**: Automated with prune and self-heal

## Adding a New Application

### 1. Create the application directory

```bash
mkdir kubernetes/apps/myapp
```

### 2. Add Kustomize or Helm configuration

**Option A: Kustomize with Helm chart**

```yaml
# kubernetes/apps/myapp/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: myapp

resources:
  - namespace.yaml

helmCharts:
  - name: mychart
    repo: https://charts.example.com
    version: 1.0.0
    releaseName: myapp
    namespace: myapp
```

**Option B: Plain Kustomize**

```yaml
# kubernetes/apps/myapp/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: myapp

resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
```

### 3. Add namespace definition

```yaml
# kubernetes/apps/myapp/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  labels:
    app.kubernetes.io/name: myapp
```

### 4. Add secrets using Sealed Secrets

```bash
# Create the secret
kubectl create secret generic myapp-secret \
  --namespace=myapp \
  --from-literal=API_KEY=your-secret-value \
  --dry-run=client -o yaml > kubernetes/apps/myapp/secret.yaml

# Seal it
kubeseal --controller-name=sealed-secrets \
  --controller-namespace=sealed-secrets \
  -f kubernetes/apps/myapp/secret.yaml \
  -o yaml > kubernetes/apps/myapp/sealedsecret.yaml

# Delete the plain secret (it's gitignored, but good practice)
rm kubernetes/apps/myapp/secret.yaml

# Add to kustomization.yaml resources
```

### 5. Commit and push

ArgoCD will automatically detect the new directory and create an Application.

## Applications

### sealed-secrets

[Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) controller for encrypting Kubernetes secrets.

- **Namespace**: `sealed-secrets`
- **Helm Chart**: `bitnami-labs/sealed-secrets` v2.18.0

### cloudflared

[Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) connector for secure ingress without exposing ports.

- **Namespace**: `cloudflared`
- **Helm Chart**: `cloudflare/cloudflare-tunnel-remote` v0.1.2
- **Secret**: Tunnel token stored as SealedSecret

## Patching Helm Charts

Use Kustomize patches to modify Helm-rendered resources:

```yaml
# kustomization.yaml
patches:
  - target:
      kind: Deployment
      name: myapp-deployment
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
```

## Troubleshooting

```bash
# Check ApplicationSet status
kubectl get applicationset -n argocd

# Check Applications
kubectl get applications -n argocd

# Check specific app sync status
kubectl get application myapp -n argocd -o yaml

# Force refresh
argocd app refresh myapp

# Check sealed secret decryption
kubectl get sealedsecret -n myapp
kubectl get secret -n myapp
```
