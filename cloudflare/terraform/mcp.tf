resource "cloudflare_zero_trust_access_policy" "forgejo_mcp_service_token" {
  name             = "TF - Forgejo MCP Service Token"
  account_id       = var.cloudflare_account_id
  decision         = "non_identity"
  session_duration = "24h"

  include = [
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.forgejo_mcp.id
      }
    }
  ]
  require = []
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
      id         = cloudflare_zero_trust_access_policy.forgejo_mcp_service_token.id,
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
  name       = "TF - Forgejo MCP"
  hostname   = "https://forgejo-mcp.${var.tld}/mcp"
  auth_type  = "bearer"

  # Cloudflare AI Controls sync is a machine identity, so it authenticates to the
  # Access-protected upstream using a service token sent as static headers. The
  # interactive "oauth" auth_type cannot be used here: Access rejects the replayed
  # admin OAuth token with 401 invalid_token during background sync.
  auth_credentials = jsonencode({
    headers = {
      "CF-Access-Client-Id"     = cloudflare_zero_trust_access_service_token.forgejo_mcp.client_id
      "CF-Access-Client-Secret" = cloudflare_zero_trust_access_service_token.forgejo_mcp.client_secret
    }
  })

  updated_prompts = []
  updated_tools   = []

  # Do NOT add `lifecycle { ignore_changes = [auth_credentials] }`: the API does a
  # full-object replace on update, so any update that omits auth_credentials (which
  # is what ignore_changes causes) wipes the stored headers -> upstream sync fails
  # with "Bearer credentials missing headers". Keeping auth_credentials in config
  # means every update re-sends the headers. Steady state is a no-op (the provider
  # does not null the write-only field on read), so this only matters when the
  # service token rotates, in which case the update flips status ready -> waiting
  # and may surface a one-off "inconsistent result after apply" provider error;
  # the credentials are still applied correctly and the server re-syncs to ready.

  depends_on = [
    cloudflare_zero_trust_access_application.forgejo_mcp,
    cloudflare_zero_trust_access_policy.forgejo_mcp_service_token,
  ]
}
