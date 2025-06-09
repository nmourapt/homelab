
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_prod" {
  account_id = var.cloudflare_account_id
  name = "lis_prod"
  config_src = "cloudflare"
}

output "lis_prod_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_prod_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id
  config = {
    ingress = [
      {
        hostname = "warden.${var.tld}"
        service = "http://vaultwarden:80"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "down.${var.tld}"
        service = "http://qbittorrent:8080"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "vaultwarden_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "warden"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "qbittorrent_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "down"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}