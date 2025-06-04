
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
        service = "http_status:404"
      }
    ]
  }
}