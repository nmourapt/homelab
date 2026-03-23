
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_claw" {
  account_id = var.cloudflare_account_id
  name = "TF-lis_claw"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_claw_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_claw]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_claw.id
  config = {
    ingress = [
      {
        hostname = "sshclaw.${var.tld}"
        service = "ssh://localhost:22"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "sshclaw_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_claw]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "sshclaw"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_claw.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_claw", "cloudflared", "tunnel"]
}

resource "cloudflare_zero_trust_access_application" "sshclaw_admin" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - SSH OpenClaw"
  type                 = "ssh"
  session_duration     = "8h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
  ]
  auto_redirect_to_identity = true

  policies = [
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins.id,
      precedence = 1
    },
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins_row.id,
      precedence = 2
    }
  ]

  app_launcher_visible = true
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/openclaw.png"

  destinations = [
    { 
      type = "public"
      uri = "warden.${var.tld}/admin"
    }
  ]
}
