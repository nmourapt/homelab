resource "cloudflare_zero_trust_access_application" "sso_app" {
  provider             = cloudflare.global_key
  account_id           = var.cloudflare_account_id
  name                 = "SSO App"
  type                 = "dash_sso"
  session_duration     = "24h"

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
            domain = "${var.tld_alt}"
          }
        }
      ]
      name       = "allow email domain"
      precedence = 3
    }
  ]

  lifecycle {
    ignore_changes = [app_launcher_visible]
  }

  saas_app = {
    auth_type = "saml"
  }
}

resource "cloudflare_zero_trust_access_application" "vaultwarden_app" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Vaultwarden"
  type                 = "saas"
  session_duration     = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid.id
  ]
  auto_redirect_to_identity = true

  policies = [
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_everyone.id,
      precedence = 1
    }
  ]

  app_launcher_visible = true
  logo_url = "https://s3-eu-west-1.amazonaws.com/tpd/logos/5c92a3d0634b4d00012fa165/0x0.png"

  saas_app = {
    auth_type = "oidc"
    app_launcher_url = "https://warden.${var.tld}"
    redirect_uris = [
      "https://warden.${var.tld}/identity/connect/oidc-signin"
    ]
    grant_types = [
      "authorization_code_with_pkce",
      "refresh_tokens"   
    ]
    scopes = [
      "openid",
      "email",
      "profile",
    ]
    access_token_lifetime = "24h"
    refresh_token_options = {
      lifetime = "30d"
    }
  }
}

resource "cloudflare_zero_trust_access_application" "vaultwarden_admin" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Vaultwarden Admin"
  type                 = "self_hosted"
  session_duration     = "30m"

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
    }
  ]

  app_launcher_visible = true
  logo_url = "https://s3-eu-west-1.amazonaws.com/tpd/logos/5c92a3d0634b4d00012fa165/0x0.png"

  destinations = [
    { 
      type = "public"
      uri = "warden.${var.tld}/admin"
    }
  ]
}


resource "cloudflare_zero_trust_access_application" "qbittorrent" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Down"
  type                 = "self_hosted"
  session_duration     = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid.id
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
    }
  ]

  app_launcher_visible = true
  logo_url = "https://upload.wikimedia.org/wikipedia/commons/6/66/New_qBittorrent_Logo.svg"

  destinations = [
    { 
      type = "public"
      uri = "down.${var.tld}"
    }
  ]
}
