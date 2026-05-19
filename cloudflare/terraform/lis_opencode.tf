
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_opencode" {
  account_id = var.cloudflare_account_id
  name = "TF-lis_opencode"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_opencode_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id
  config = {
    ingress = [
      {
        hostname = "opencode.${var.tld}"
        service = "http://host.docker.internal:8080"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "opencodessh.${var.tld}"
        service = "ssh://host.docker.internal:22"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "opencode_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "opencode"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_opencode", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "opencodessh_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "opencodessh"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_opencode", "cloudflared", "tunnel"]
}
