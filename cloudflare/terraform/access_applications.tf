resource "cloudflare_zero_trust_access_application" "sso_app" {
  provider             = cloudflare.global_key
  account_id           = var.cloudflare_account_id
  name                 = "SSO App"
  type                 = "dash_sso"
  session_duration     = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id,
    cloudflare_zero_trust_access_identity_provider.google.id
  ]
  auto_redirect_to_identity = false

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

resource "cloudflare_zero_trust_access_application" "upload_assistant" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Upload Assistant"
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
  logo_url = "https://img.icons8.com/color/1200/torrent.jpg"

  destinations = [
    { 
      type = "public"
      uri = "upload.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "netboot" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Netboot"
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
  logo_url = "https://netboot.xyz/img/nbxyz-logo.svg"

  destinations = [
    { 
      type = "public"
      uri = "netboot.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "jetkvm" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - JetKVM"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jetkvm.png"

  destinations = [
    { 
      type = "public"
      uri = "kvm.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "omni_app" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Omni"
  type                 = "saas"
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
  logo_url = "https://mintlify.s3.us-west-1.amazonaws.com/siderolabs-fe86397c/images/omni.svg"

  saas_app = {
    auth_type = "oidc"
    app_launcher_url = "https://cluster.${var.tld}"
    redirect_uris = [
      "https://cluster.${var.tld}/oidc/consume"
    ]
    grant_types = [
      "authorization_code"
    ]
    scopes = [
      "openid",
      "email",
      "profile",
    ]
  }
}

resource "cloudflare_zero_trust_access_application" "argo_oidc" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - ArgoCD"
  type                 = "saas"
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
  logo_url = "https://argo-cd.readthedocs.io/en/stable/assets/logo.png"

  saas_app = {
    auth_type = "oidc"
    app_launcher_url = "https://argo.${var.tld}"
    access_token_lifetime = "24h"
    redirect_uris = [
      "https://argo.${var.tld}/auth/callback"
    ]
    grant_types = [
      "authorization_code_with_pkce",
      "refresh_tokens"
    ]
    refresh_token_options = {
      lifetime = "1d"
    }
    scopes = [
      "openid",
      "email",
      "profile",
      "groups",
    ]
    custom_claims = [
      {
        name  = "groups"
        scope = "groups"
        source = {
          name = "groups"
        }
        required = true
      }
    ]
  }
}

resource "cloudflare_zero_trust_access_application" "traefik" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Traefik"
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
  logo_url = "https://www.onworks.net/imagescropped/traefikicon.png_3.webp"

  destinations = [
    { 
      type = "public"
      uri = "traefik.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "grafana_oidc" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Grafana"
  type                 = "saas"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/grafana.png"

  saas_app = {
    auth_type = "oidc"
    app_launcher_url = "https://grafana.${var.tld}"
    access_token_lifetime = "24h"
    redirect_uris = [
      "https://grafana.${var.tld}/login/generic_oauth"
    ]
    grant_types = [
      "authorization_code",
    ]
    scopes = [
      "openid",
      "email",
      "profile",
      "groups",
    ]
  }
}

resource "cloudflare_zero_trust_access_application" "prometheus" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Prometheus"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prometheus.png"

  destinations = [
    { 
      type = "public"
      uri = "prometheus.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "alertmanager" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Alertmanager"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/alertmanager.png"

  destinations = [
    { 
      type = "public"
      uri = "alertmanager.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "longhorn" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Longhorn"
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
  logo_url = "https://longhorn.io/img/logos/longhorn-icon-color.png"

  destinations = [
    { 
      type = "public"
      uri = "longhorn.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "seerr" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Seerr"
  type                 = "self_hosted"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/overseerr.png"

  destinations = [
    { 
      type = "public"
      uri = "requests.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "sonarr" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Sonarr"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/sonarr.png"

  destinations = [
    { 
      type = "public"
      uri = "tv.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "radarr" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Radarr"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/radarr.png"

  destinations = [
    { 
      type = "public"
      uri = "movies.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "prowlarr" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Prowlarr"
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
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prowlarr.png"

  destinations = [
    { 
      type = "public"
      uri = "indexer.${var.tld}"
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "cf_metrics" {
  account_id           = var.cloudflare_account_id
  name                 = "TF - Cloudflare Metrics"
  type                 = "self_hosted"
  session_duration     = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid.id
  ]
  auto_redirect_to_identity = false

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.service_token_prometheus_cf_metrics.id,
      precedence = 1
    },
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins.id,
      precedence = 2
    },
    { 
      id = cloudflare_zero_trust_access_policy.pocketid_admins_row.id,
      precedence = 3
    }
  ]

  app_launcher_visible = true
  logo_url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cloudflare.png"

  destinations = [
    { 
      type = "public"
      uri = "cf-metrics.${var.tld}"
    }
  ]
}

