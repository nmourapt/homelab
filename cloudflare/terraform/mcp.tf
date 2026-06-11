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
      id         = cloudflare_zero_trust_access_policy.pocketid_admins.id,
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_admins_row.id,
      precedence = 2
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
