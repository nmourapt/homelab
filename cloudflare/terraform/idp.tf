
resource "cloudflare_zero_trust_access_identity_provider" "pocketid" {
  account_id = var.cloudflare_account_id
  name       = "Pocket ID"
  type       = "oidc"
  config = {
    client_id = var.pocketid_client_id
    client_secret = var.pocketid_client_secret
    auth_url = "https://oidc.${var.tld}/authorize"
    token_url = "https://oidc.${var.tld}/api/oidc/token"
    certs_url = "https://oidc.${var.tld}/.well-known/jwks.json"
    pkce_enabled = true
    email_claim_name = "email"
    claims = ["groups"]
    scopes = ["openid", "email", "profile", "groups"]
  }
  scim_config = {
    enabled = true
    identity_update_behavior = "automatic"
    seat_deprovision = true
    user_deprovision = true
  }
}

resource "cloudflare_zero_trust_access_identity_provider" "pocketid_reauth" {
  account_id = var.cloudflare_account_id
  name       = "Pocket ID Reauth"
  type       = "oidc"
  config = {
    client_id = var.pocketid_reauth_client_id
    client_secret = var.pocketid_client_secret
    auth_url = "https://oidc.${var.tld}/authorize"
    token_url = "https://oidc.${var.tld}/api/oidc/token"
    certs_url = "https://oidc.${var.tld}/.well-known/jwks.json"
    pkce_enabled = true
    email_claim_name = "email"
    claims = ["groups"]
    scopes = ["openid", "email", "profile", "groups"]
  }
  scim_config = {
    enabled = true
    identity_update_behavior = "automatic"
    seat_deprovision = true
    user_deprovision = true
  }
}
