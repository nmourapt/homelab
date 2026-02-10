
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_k8s" {
  account_id = var.cloudflare_account_id
  name = "tf_lis_k8s"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_k8s_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_k8s]
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.lis_k8s.id
  config = {
    ingress = [
      {
        hostname = "argo.${var.tld}"
        service = "https://argocd-server.argocd.svc.cluster.local:443"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "traefik.${var.tld}"
        service = "http://traefik.traefik.svc.cluster.local:8080"
        origin_request = {
          http2_origin = true
          no_tls_verify = true
        }
      },
      {
        hostname = "*.${var.tld}"
        service = "https://traefik.traefik.svc.cluster.local:443"
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

resource "cloudflare_dns_record" "argo_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_k8s]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "argo"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_k8s.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_k8s", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "traefik_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_k8s]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "traefik"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lis_k8s.id}.cfargotunnel.com"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_k8s", "cloudflared", "tunnel"]
}
