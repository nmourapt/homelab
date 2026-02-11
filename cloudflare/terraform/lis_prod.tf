
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_prod" {
  account_id = var.cloudflare_account_id
  name = "TF-lis_prod"
  config_src = "cloudflare"
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
        hostname = "oidc.${var.tld}"
        service = "http://pocketid:1411"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "ha.${var.tld}"
        service = "http://192.168.101.65:8123"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "kvm.${var.tld}"
        service = "http://192.168.101.108:80"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "*.${var.tld}"
        service = "http://traefik:80"
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

resource "cloudflare_dns_record" "homeassistant_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "ha"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "kvm_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "kvm"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "pocketid_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "oidc"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_prod.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}
