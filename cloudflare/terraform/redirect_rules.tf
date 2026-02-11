resource "cloudflare_ruleset" "redirect_rules" {
  zone_id     = var.cloudflare_tld_zone_id
  name        = "Redirect Rules"
  description = "Zone-level redirect rules"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "traefik_dashboard_redirect"
      description = "Redirect traefik root to /dashboard/"
      expression  = "(http.host eq \"traefik.${var.tld}\" and http.request.uri.path eq \"/\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            value = "https://traefik.${var.tld}/dashboard/"
          }
          preserve_query_string = false
        }
      }
    }
  ]
}
