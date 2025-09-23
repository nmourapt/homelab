
resource "cloudflare_zone" "spectrum_zone" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "spectrum.${var.tld}"
  type = "full"
}

resource "cloudflare_zone_subscription" "spectrum_zone_subscription" {
  zone_id = cloudflare_zone.spectrum_zone.id
  frequency = "monthly"
  rate_plan = {
    id = "enterprise"
    externally_managed = false
  }
}

resource "cloudflare_dns_record" "spectrum_ns1_record" {
  depends_on = [cloudflare_zone.spectrum_zone]
  zone_id = var.cloudflare_tld_zone_id
  type = "NS"
  name = "spectrum"
  content = cloudflare_zone.spectrum_zone.name_servers[0]
  ttl = 1
  comment = "Managed by terraform - do not edit"
  tags = ["terraform", "lis_isp", "cloudflared", "tunnel"]
}
resource "cloudflare_dns_record" "spectrum_ns2_record" {
  depends_on = [cloudflare_zone.spectrum_zone]
  zone_id = var.cloudflare_tld_zone_id
  type = "NS"
  name = "spectrum"
  content = cloudflare_zone.spectrum_zone.name_servers[1]
  ttl = 1
  comment = "Managed by terraform - do not edit"
  tags = ["terraform", "lis_isp", "cloudflared", "tunnel"]
}

resource "cloudflare_spectrum_application" "squid_spectrum_app" {
  provider = cloudflare.global_key
  zone_id = cloudflare_zone.spectrum_zone.id
  dns = {
    name = "spectrum.nmoura.pt"
    type = "CNAME"
  }
  protocol = "tcp/3128"
  traffic_type = "direct"
  argo_smart_routing = true
  edge_ips = {
    connectivity = "ipv4"
    type = "dynamic"
  }
  ip_firewall = true
  origin_dns = {
    name = "home.nmoura.pt"
  }
  origin_port = 3128
  proxy_protocol = "off"
  tls = "off"
}

resource "cloudflare_access_rule" "allow_portugal_rule" {
  configuration = {
    target = "country"
    value = "PT"
  }
  mode = "whitelist"
  zone_id = cloudflare_zone.spectrum_zone.id
  notes = "Managed by terraform - do not edi"
}