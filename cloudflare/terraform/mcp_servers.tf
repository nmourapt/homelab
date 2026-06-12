# Additional MCP servers registered in Cloudflare AI Controls and exposed through
# the MCP portal. The Forgejo server (auth via Access service token) lives in
# mcp.tf alongside its Access application.
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
