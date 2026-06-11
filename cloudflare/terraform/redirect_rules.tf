resource "cloudflare_ruleset" "redirect_rules" {
  zone_id     = var.cloudflare_tld_zone_id
  name        = "Redirect Rules"
  description = "Zone-level redirect rules"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      ref         = "traefik_dashboard_redirect"
      description = "TF - Redirect traefik root to /dashboard/"
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
    },
    {
      ref         = "forgejo_sso_redirect"
      description = "TF - Auto-redirect Forgejo login to Cloudflare SSO"
      expression  = "(http.host eq \"git.${var.tld}\" and http.request.uri.path eq \"/user/login\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 302
          target_url = {
            value = "https://git.${var.tld}/user/oauth2/cloudflare"
          }
          preserve_query_string = false
        }
      }
    }
  ]
}
