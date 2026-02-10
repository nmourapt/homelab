
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_isp" {
  account_id = var.cloudflare_account_id
  name = "tf_lis_isp"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_isp_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_isp]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_isp.id
  config = {
    ingress = [
      {
        hostname = "omada.${var.tld}"
        service = "https://192.168.1.99:443"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "isp.${var.tld}"
        service = "http://192.168.1.254:80"
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

resource "cloudflare_dns_record" "omada_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_isp]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "omada"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_isp.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_isp", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "isp_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_isp]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "isp"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_isp.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_isp", "cloudflared", "tunnel"]
}
