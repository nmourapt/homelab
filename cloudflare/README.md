# Cloudflare Infrastructure

Terraform configuration for managing Cloudflare resources.

## Resources Managed

| File | Description |
|------|-------------|
| `access_applications.tf` | Cloudflare Access applications (protected services) |
| `access_policies.tf` | Access policies (who can access what) |
| `dns.tf` | DNS records |
| `idp.tf` | Identity providers (PocketID, Google) |
| `lis_isp.tf` | Cloudflare Tunnel for ISP connection |
| `lis_prod.tf` | Cloudflare Tunnel for production services |
| `spectrum.tf` | Spectrum applications (TCP/UDP proxying) |
| `zt_lists.tf` | Zero Trust lists |

## Authentication

Two provider configurations are used:

- **API Token** (default): Scoped token for most operations
- **Global API Key** (`global_key` alias): Required for certain legacy APIs

## State Backend

Terraform state is stored in Cloudflare R2:

```hcl
backend "s3" {
  bucket = "terraform-state"
  key    = "cloudflare/terraform.tfstate"
  # R2 endpoint configured via AWS credentials
}
```

## Variables

All sensitive variables are passed via GitHub Secrets → Terraform environment variables:

| Variable | Description |
|----------|-------------|
| `cloudflare_api_token` | API token with required permissions |
| `cloudflare_account_id` | Cloudflare account ID |
| `cloudflare_tld_zone_id` | Zone ID for primary domain |
| `tld` | Primary domain (e.g., `example.com`) |
| `tld_alt` | Alternative domain |
| `pocketid_client_*` | PocketID OIDC credentials |
| `google_client_*` | Google OIDC credentials |
| `egress_ips_json` | JSON list of egress IPs for access policies |

## Local Development

```bash
cd cloudflare/terraform

# Initialize with local backend for testing
terraform init -backend-config=backend-local.hcl

# Set required variables
export TF_VAR_cloudflare_api_token="..."
export TF_VAR_cloudflare_account_id="..."
# ... etc

terraform plan
```

## Deployment

Automatically deployed via GitHub Actions when changes are pushed to `cloudflare/terraform/*.tf`.

See `.github/workflows/deploy-cloudflare.yml`.
