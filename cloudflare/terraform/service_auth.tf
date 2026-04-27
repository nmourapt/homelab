
resource "cloudflare_zero_trust_access_service_token" "prometheus_cf_metrics" {
  account_id = var.cloudflare_account_id
  name       = "TF - Prometheus cf-metrics"
  duration   = "forever"
}

resource "cloudflare_zero_trust_access_service_token" "openclaw_service_token" {
  account_id = var.cloudflare_account_id
  name       = "TF - Openclaw WARP"
  duration   = "forever"
}

resource "cloudflare_zero_trust_access_service_token" "nasdoctor_service_token" {
  account_id = var.cloudflare_account_id
  name       = "TF - nasdoctor"
  duration   = "forever"
}
