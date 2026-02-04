
resource "cloudflare_dns_record" "omniapi_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "clusterapi"
  content = "home.${var.tld}"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = false
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "omni_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_prod]
  zone_id = var.cloudflare_tld_zone_id
  type = "CNAME"
  name = "cluster"
  content = "home.${var.tld}"
  ttl = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags = ["terraform", "lis_prod", "cloudflared", "tunnel"]
}