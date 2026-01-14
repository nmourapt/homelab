resource "cloudflare_zero_trust_access_application" "sso_app" {
  account_id = var.cloudflare_account_id
  name = "SSO App"
  type = "dash_sso"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
  ]
  auto_redirect_to_identity = true

  policies = [
    {
      decision = "allow"
      id = cloudflare_zero_trust_access_policy.pocketid_admins.id
      precedence = 0
    },
    {
      decision = "allow"
      id = cloudflare_zero_trust_access_policy.pocketid_admins_row.id
      precedence = 1
    },
  ]

  app_launcher_visible = true
  logo_url = "https://seeklogo.com/images/C/cloudflare-logo-6B7D159387-seeklogo.com.png"
}