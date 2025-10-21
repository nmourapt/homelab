
resource "cloudflare_zero_trust_access_identity_provider" "pocketid" {
  account_id = var.cloudflare_account_id
  name       = "Pocket ID"
  type       = "oidc"
  config = {
    client_id = var.pocketid_client_id
    client_secret = var.pocketid_client_secret
    auth_url = "https://oidc.${var.tld}/"
    token_url = "https://oidc.${var.tld}/token"
    certs_url = "https://oidc.${var.tld}/.well-known/openid-configuration"
    pkce_enabled = true
    email_claim_name = "email"
    claims = ["groups"]
    scopes = ["openid", "email", "profile"]
  }
}
