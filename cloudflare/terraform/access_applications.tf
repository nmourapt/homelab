# Import with: terraform import cloudflare_zero_trust_access_application.sso_app <account_id>/096f1074-4a80-4dfe-9d9e-0173af52aecc
# Then run: terraform plan to see the current state and fill in this resource

resource "cloudflare_zero_trust_access_application" "sso_app" {
  provider         = cloudflare.global_key
  account_id       = var.cloudflare_account_id
  name             = "SSO App"
  type             = "dash_sso"
  session_duration = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
  ]
  auto_redirect_to_identity = true

  policies = [
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins.id,
      precedence = 1
    },
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins_row.id,
      precedence = 2
    },
    { 
      decision   = "allow"
      include    = [
        {
          email_domain = {
            domain = "babybites.pt"
          }
        }
      ]
      name       = "allow email domain"
      precedence = 3
    }
  ]

  saas_app = {
    auth_type = "saml"
  }
}
