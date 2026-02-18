
resource "cloudflare_zero_trust_access_service_token" "prometheus_cf_metrics" {
  account_id = var.cloudflare_account_id
  name       = "TF - Prometheus cf-metrics"
  duration   = "forever"
}
