resource "cloudflare_zero_trust_access_group" "pocket_id_idps" {
  name       = "TF - Pocket ID Instances"
  account_id = var.cloudflare_account_id
  include = [
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.pocketid.id
      }
    },
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_policy" "pocketid_admins" {
  name             = "TF - Pocket ID Admins - Portugal"
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  session_duration = "8h"

  include = [
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "administrators"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid.id
      }
    },
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "administrators"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
      }
    }
  ]
  require = [
    {
      geo = {
        country_code = "PT"
      }
    },
    {
      group = {
        id = cloudflare_zero_trust_access_group.pocket_id_idps.id
      }
    }
  ]
  exclude = []
}


resource "cloudflare_zero_trust_access_policy" "pocketid_admins_row" {
  name             = "TF - Pocket ID Admins - RoW"
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  session_duration = "15m"

  include = [
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "administrators"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid.id
      }
    },
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "administrators"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
      }
    }
  ]
  require = [
    {
      geo = {
        country_code = "PT"
      }
    },
    {
      group = {
        id = cloudflare_zero_trust_access_group.pocket_id_idps.id
      }
    }
  ]
  exclude = []
}

resource "cloudflare_zero_trust_access_policy" "pocketid_everyone" {
  name             = "TF - Pocket ID Everyone"
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  session_duration = "8h"

  include = [
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "everyone"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid.id
      }
    },
    {
      oidc = {
        claim_name           = "groups"
        claim_value          = "everyone"
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
      }
    }
  ]
  exclude = []
  require = [
    {
      group = {
        id = cloudflare_zero_trust_access_group.pocket_id_idps.id
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_policy" "cloudflare" {
  name             = "TF - Cloudflare"
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  session_duration = "30m"

  include = [
    {
      email_domain = {
        domain = "cloudflare.com"
      }
    }
  ]
  exclude = []
  require = [
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.google.id
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_policy" "bypass_everyone" {
  name             = "TF - Everyone"
  account_id       = var.cloudflare_account_id
  decision         = "bypass"
  session_duration = "24h"

  include = [
    {
      everyone = {}
    }
  ]
  exclude = []
  require = []
}

resource "cloudflare_zero_trust_access_policy" "bypass_egress_ips" {
  name             = "TF - Egress IPs"
  account_id       = var.cloudflare_account_id
  decision         = "bypass"
  session_duration = "24h"

  include = [
    {
      ip_list = {
        id = cloudflare_zero_trust_list.egress_ips.id
      }
    }
  ]
  exclude = []
  require = []
}


resource "cloudflare_zero_trust_access_policy" "personal_email_list" {
  name             = "TF - Personal Emails"
  account_id       = var.cloudflare_account_id
  decision         = "allow"
  session_duration = "30m"

  include = [
    {
      email_list = {
        id = cloudflare_zero_trust_list.personal_emails.id
      }
    }
  ]
  exclude = []
  require = [
    {
      login_method = {
        id = cloudflare_zero_trust_access_identity_provider.google.id
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_policy" "service_token_prometheus_cf_metrics" {
  name             = "TF - Prometheus cf-metrics"
  account_id       = var.cloudflare_account_id
  decision         = "non_identity"
  session_duration = "24h"

  include = [
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.prometheus_cf_metrics.id
      }
    }
  ]
  exclude = []
  require = []
}