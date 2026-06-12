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
  account_id = var.cloudflare_account_id
  id         = "forgejo-mcp"
  name       = "TF - Forgejo"
  hostname   = "https://forgejo-mcp.${var.tld}/mcp"
  auth_type  = "bearer"

  auth_credentials = jsonencode({
    headers = {
      "CF-Access-Client-Id"     = cloudflare_zero_trust_access_service_token.forgejo_mcp.client_id
      "CF-Access-Client-Secret" = cloudflare_zero_trust_access_service_token.forgejo_mcp.client_secret
    }
  })

  updated_prompts = []
  updated_tools   = []

  depends_on = [
    cloudflare_zero_trust_access_application.forgejo_mcp,
    cloudflare_zero_trust_access_policy.forgejo_mcp_service_token,
  ]
}

# Additional MCP servers registered in Cloudflare AI Controls and exposed through
# the MCP portal below.
#
# Credential notes:
#   - "unauthenticated" servers need no auth_credentials.
#   - "oauth" servers (Cloudflare's public MCP endpoints) use Cloudflare managed
#     OAuth. The tokens are obtained interactively and cannot be expressed in
#     HCL, so after these are created they must be authorized once in the
#     dashboard (AI Controls -> the server -> Authenticate). Do NOT add
#     auth_credentials for them.
#   - "bearer" servers send static headers; Home Assistant uses a long-lived
#     access token supplied via the SOPS-backed var.homeassistant_mcp_token.

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "cloudflare_docs" {
  account_id = var.cloudflare_account_id
  id         = "cloudflare-docs"
  name       = "TF - Cloudflare Docs"
  hostname   = "https://docs.mcp.cloudflare.com/mcp"
  auth_type  = "unauthenticated"

  updated_prompts = []
  updated_tools   = []
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "cloudflare_radar" {
  account_id = var.cloudflare_account_id
  id         = "cloudflare-radar"
  name       = "TF - Cloudflare Radar"
  hostname   = "https://radar.mcp.cloudflare.com/mcp"
  auth_type  = "oauth"

  updated_prompts = []
  updated_tools   = []
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "cloudflare_graphql" {
  account_id = var.cloudflare_account_id
  id         = "cloudflare-graph-ql"
  name       = "TF - Cloudflare GraphQL"
  hostname   = "https://graphql.mcp.cloudflare.com/mcp"
  auth_type  = "oauth"

  updated_prompts = []
  updated_tools   = []
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "cloudflare_api" {
  account_id = var.cloudflare_account_id
  id         = "cloudflare-api"
  name       = "TF - Cloudflare API"
  hostname   = "https://mcp.cloudflare.com/mcp"
  auth_type  = "oauth"

  updated_prompts = []
  updated_tools   = []
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "home_assistant" {
  account_id = var.cloudflare_account_id
  id         = "home-assistant"
  name       = "TF - Home Assistant"
  hostname   = "https://ha.${var.tld}/api/mcp"
  auth_type  = "bearer"

  auth_credentials = jsonencode({
    headers = {
      "Authorization" = "Bearer ${var.homeassistant_mcp_token}"
    }
  })

  updated_prompts = []
  updated_tools   = []
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_portal" "mcp_portal" {
  account_id         = var.cloudflare_account_id
  id                 = "mcp-portal"
  name               = "TF - MCP Portal"
  hostname           = "mcp.${var.tld}"
  allow_code_mode    = true
  secure_web_gateway = false

  servers = [
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.forgejo_mcp.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.home_assistant.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_docs.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_radar.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_graphql.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
    {
      server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_api.id
      on_behalf        = false
      default_disabled = false
      updated_prompts  = []
      updated_tools    = []
    },
  ]

  depends_on = [
    cloudflare_zero_trust_access_ai_controls_mcp_server.forgejo_mcp,
    cloudflare_zero_trust_access_ai_controls_mcp_server.home_assistant,
    cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_docs,
    cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_radar,
    cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_graphql,
    cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_api,
  ]
}

# Per-server "mcp" Access applications. Each MCP server exposed through the
# portal needs a type="mcp" Access app whose destination binds to the server via
# mcp_server_id. These hold the Allow policies that control whether the server is
# visible to a user in the portal. Without this app the server is in a broken
# state ("Access application for this MCP Portal not found").
resource "cloudflare_zero_trust_access_application" "forgejo_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Forgejo"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.forgejo_mcp.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "home_assistant_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Home Assistant"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.home_assistant.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "cloudflare_docs_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Cloudflare Docs"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_docs.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "cloudflare_radar_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Cloudflare Radar"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_radar.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "cloudflare_graphql_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Cloudflare GraphQL"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_graphql.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "cloudflare_api_mcp_app" {
  account_id = var.cloudflare_account_id
  name       = "TF - Cloudflare API"
  type       = "mcp"

  destinations = [
    {
      type          = "via_mcp_server_portal"
      mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.cloudflare_api.id
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.pocketid_everyone.id
      precedence = 1
    }
  ]
}
