
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_k8s" {
  account_id = var.cloudflare_account_id
  name = "lis_k8s"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_k8s_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_k8s]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_k8s.id
  config = {
    ingress = [
      {
        hostname = "*.${var.tld}"
        service = "https://traefik:443"
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
