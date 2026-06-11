resource "cloudflare_zero_trust_access_policy" "forgejo_mcp_admins" {
  name       = "TF - Forgejo MCP Admins"
  account_id = var.cloudflare_account_id
  decision   = "allow"

  include = [
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "administrators"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid.id
      }
    }
  ]
  require = []
  exclude = []
}

resource "cloudflare_zero_trust_access_application" "forgejo_mcp" {
  account_id       = var.cloudflare_account_id
  name             = "TF - Forgejo MCP"
  type             = "self_hosted"
  session_duration = "8h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid.id
  ]
  auto_redirect_to_identity = true

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.forgejo_mcp_admins.id,
      precedence = 1
    }
  ]

  destinations = [
    {
      type = "public"
      uri  = "forgejo-mcp.${var.tld}"
    }
  ]

  oauth_configuration = {
    enabled = true
    dynamic_client_registration = {
      enabled = true
      allowed_uris = [
        "https://oauth-callbacks.cloudflareaccess.com/cdn-cgi/access/outbound-oauth-callback",
        "https://dash.cloudflare.com/${var.cloudflare_account_id}/one/access-controls/ai-controls/mcp-server/oauth-callback/*"
      ]
    }
  }
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "forgejo_mcp" {
  provider   = cloudflare.global_key
  account_id = var.cloudflare_account_id
  id         = "forgejo-mcp"
  name       = "Forgejo MCP"
  hostname   = "https://forgejo-mcp.${var.tld}/mcp"
  auth_type  = "oauth"

  updated_prompts = []
  updated_tools   = []

  depends_on = [cloudflare_zero_trust_access_application.forgejo_mcp]
}
