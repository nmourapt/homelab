
resource "cloudflare_zero_trust_tunnel_cloudflared" "oci_claw" {
  account_id = var.cloudflare_account_id
  name = "TF-oci_claw"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "oci_claw_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.oci_claw]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.oci_claw.id
  config = {
    ingress = [
      {
        hostname = "clawssh.${var.tld}"
        service = "ssh://localhost:22"
      },
      {
        hostname = "clawgate.${var.tld}"
        service = "http://localhost:18789"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "clawssh_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.oci_claw]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "clawssh"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.oci_claw.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "oci_claw", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "clawgate_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.oci_claw]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "clawgate"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.oci_claw.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "oci_claw", "cloudflared", "tunnel"]
}

resource "cloudflare_zero_trust_access_application" "clawssh_admin" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - SSH OCI Openclaw"
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
      uri = "clawssh.${var.tld}"
    }
  ]
}
