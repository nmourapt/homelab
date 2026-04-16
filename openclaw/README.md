# OpenClaw

OCI Always Free ARM instance running on an Ampere A1.Flex (4 OCPU, 24 GB RAM, 100 GB boot volume) in eu-frankfurt-1. Provisioned via Terraform with cloud-init bootstrapping a `nuno` user and cloudflared tunnel — no public IP, no bastion, all access through Cloudflare.

## Architecture

The instance sits in a private subnet with no inbound internet access. A NAT Gateway provides outbound-only connectivity for package installation and cloudflared's outbound tunnel. SSH and any future services are exposed exclusively through Cloudflare Tunnel, with Zero Trust Access policies defined in the [Cloudflare Terraform stack](../cloudflare/terraform/oci_claw.tf).

## Terraform Structure

| File | What it manages |
|------|----------------|
| `compute.tf` | A1.Flex instance, Ubuntu 24.04 aarch64 image lookup, cloud-init |
| `network.tf` | VCN, private subnet, NAT gateway, internet gateway, route table, security list |
| `cloud-init.yaml.tftpl` | User creation (`nuno`), cloudflared installation and service registration |
| `provider.tf` | OCI provider with API key authentication |
| `backend.tf` | R2 state backend (shared `tf-state` bucket) |
| `vars.tf` | Input variables |
| `outputs.tf` | Instance private IP, resource OCIDs |

## Cloudflare Integration

The tunnel (`TF-oci_claw`) and its ingress rules, DNS records, and Access applications are managed in the Cloudflare Terraform stack — not here. This stack only consumes the tunnel token to run cloudflared.

| Hostname | Service |
|----------|---------|
| `clawssh.<tld>` | SSH (Cloudflare Access SSH proxy) |
| `clawgate.<tld>` | OpenClaw web UI (port 18789) |

## Secrets

All secrets live in `secrets/reposecrets.sops.yml` and are pushed to GitHub Secrets via the `push-secrets` workflow.

| Secret | Purpose |
|--------|---------|
| `OCI_TENANCY_OCID` | OCI tenancy identifier |
| `OCI_USER_OCID` | OCI API user |
| `OCI_FINGERPRINT` | API signing key fingerprint |
| `OCI_PRIVATE_KEY` | PEM private key for OCI API auth |
| `OCI_REGION` | `eu-frankfurt-1` |
| `OCI_COMPARTMENT_OCID` | Compartment (root for free tier) |
| `OCI_SSH_PUBLIC_KEY` | SSH public key for the `nuno` user |
| `OCI_CLOUDFLARED_TOKEN` | Tunnel token from Cloudflare TF output |
| `R2_TF_OPENCLAW_ACCESS_KEY_ID` | R2 credentials for TF state backend |
| `R2_TF_OPENCLAW_SECRET_ACCESS_KEY` | R2 credentials for TF state backend |

State is stored in Cloudflare R2 alongside the other Terraform stacks.
