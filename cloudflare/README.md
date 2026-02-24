# Cloudflare

Terraform-managed Cloudflare infrastructure covering the full networking and security layer for the homelab. Everything external — DNS, tunnels, access control, TCP proxying — is defined here and applied automatically via GitHub Actions.

## Architecture

### Tunnels

Three Cloudflare Tunnels provide secure ingress without exposing any ports on the home network:

| Tunnel | Purpose | Routing |
|--------|---------|---------|
| **lis_k8s** | Kubernetes services | `*.domain` → Traefik, plus direct routes for ArgoCD and Traefik dashboard |
| **lis_prod** | NAS-hosted services | Vaultwarden, PocketID, Home Assistant, JetKVM |
| **lis_isp** | ISP-side network | Omada controller (separate subnet `192.168.1.x`) |

The K8s tunnel routes wildcard traffic to Traefik, which handles TLS termination and per-service routing via IngressRoutes. ArgoCD and the Traefik dashboard have dedicated tunnel routes since they bypass Traefik's ingress.

### Zero Trust Access

Every externally-accessible service is protected by a Cloudflare Access application. Access policies are layered:

- **PocketID Admins (Portugal)** — OIDC group `administrators` + geo-fence to PT, 8-hour sessions
- **PocketID Admins (Rest of World)** — Same OIDC group, no geo-fence, 15-minute sessions
- **PocketID Everyone** — OIDC group `everyone`, for shared services
- **Bypass (Egress IPs)** — Allows service-to-service calls from known egress IPs without auth
- **Bypass (Everyone)** — For specific API endpoints that need to be publicly reachable (e.g., Bazarr webhook)
- **Service Token** — Non-identity policy for Prometheus scraping Cloudflare metrics

PocketID (self-hosted OIDC) is the primary identity provider, with Google and Google Workspace as secondary options. SCIM provisioning is enabled for automatic user sync.

### Spectrum

Cloudflare Spectrum proxies raw TCP traffic for services that can't use HTTP tunnels:

- **Squid proxy** (port 36334) — TCP proxy with Argo Smart Routing
- **Email relay** (port 1588) — Postfix SMTP relay

These use a dedicated child zone (`spectrum.domain`) with NS delegation, since Spectrum requires its own zone.

### DNS

DNS records are managed through two mechanisms:
- **Terraform** — Static records for tunnel endpoints, Spectrum, and NS delegation
- **external-dns** (in-cluster) — Dynamic records created from Kubernetes IngressRoute annotations, pointed at the K8s tunnel

## Terraform Structure

| File | What it manages |
|------|----------------|
| `lis_k8s.tf` | Kubernetes tunnel + routes (ArgoCD, Traefik, wildcard) |
| `lis_prod.tf` | NAS services tunnel + routes |
| `lis_isp.tf` | ISP network tunnel (Omada) |
| `access_applications.tf` | ~20 Zero Trust Access apps protecting each service |
| `access_policies.tf` | Reusable access policies (geo-fenced, bypass, service tokens) |
| `idp.tf` | Identity providers (PocketID, Google, OTP) |
| `spectrum.tf` | TCP proxy apps + child zone for Spectrum |
| `dns.tf` | Static DNS records |
| `redirect_rules.tf` | Zone-level URL redirects (e.g., Traefik root → `/dashboard/`) |
| `service_auth.tf` | Service tokens for machine-to-machine auth |
| `zt_lists.tf` | Zero Trust lists (egress IPs, personal emails) |

State is stored in Cloudflare R2. Two provider configurations are used: a scoped API token for most operations and the Global API Key for Spectrum (legacy API requirement).
