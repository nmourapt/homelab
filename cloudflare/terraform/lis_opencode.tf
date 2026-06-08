
resource "cloudflare_zero_trust_tunnel_cloudflared" "lis_opencode" {
  account_id = var.cloudflare_account_id
  name       = "TF-lis_opencode"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lis_opencode_config" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id
  config = {
    ingress = [
      {
        hostname = "opencode.${var.tld}"
        service  = "http://host.docker.internal:8080"
        origin_request = {
          http2_origin  = true
          no_tls_verify = true
        }
      },
      {
        hostname = "opencodeoauth.${var.tld}"
        service  = "http://host.docker.internal:19876"
      },
      {
        hostname = "opencodessh.${var.tld}"
        service  = "ssh://host.docker.internal:22"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "opencode_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  zone_id    = var.cloudflare_tld_zone_id
  type       = "CNAME"
  name       = "opencode"
  content    = "${cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id}.cfargotunnel.com"
  ttl        = 1
  comment    = "Managed by terraform - do not edit"
  proxied    = true
  tags       = ["terraform", "lis_opencode", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "opencodessh_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  zone_id    = var.cloudflare_tld_zone_id
  type       = "CNAME"
  name       = "opencodessh"
  content    = "${cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id}.cfargotunnel.com"
  ttl        = 1
  comment    = "Managed by terraform - do not edit"
  proxied    = true
  tags       = ["terraform", "lis_opencode", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "opencodeoauth_record" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.lis_opencode]
  zone_id    = var.cloudflare_tld_zone_id
  type       = "CNAME"
  name       = "opencodeoauth"
  content    = "${cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id}.cfargotunnel.com"
  ttl        = 1
  comment    = "Managed by terraform - do not edit"
  proxied    = true
  tags       = ["terraform", "lis_opencode", "cloudflared", "tunnel"]
}

resource "cloudflare_dns_record" "opencode_rdp_record" {
  zone_id = var.cloudflare_tld_zone_id
  type    = "A"
  name    = "opencoderdp"
  content = "240.0.0.0"
  ttl     = 1
  comment = "Managed by terraform - do not edit"
  proxied = true
  tags    = ["terraform", "lis_opencode", "rdp"]
}


resource "cloudflare_zero_trust_tunnel_cloudflared_route" "lis_opencode_rdp_route" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lis_opencode.id
  network    = "192.168.101.178/32"
  comment    = "Managed by terraform - lis_opencode RDP"
  # virtual_network_id omitted -> default vnet (must match the target's vnet)
}

resource "cloudflare_zero_trust_access_infrastructure_target" "lis_opencode_rdp" {
  account_id = var.cloudflare_account_id
  hostname   = "TF-opencode-rdp"
  ip = {
    ipv4 = {
      ip_addr = "192.168.101.178"
      # virtual_network_id omitted -> default vnet (must match the route's vnet)
    }
  }
}

resource "cloudflare_zero_trust_access_application" "opencode_rdp" {
  account_id       = var.cloudflare_account_id
  name             = "TF - RDP Opencode"
  type             = "rdp"
  session_duration = "8h"
  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.pocketid_reauth.id
  ]
  auto_redirect_to_identity = true
  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.rdp_admins.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.rdp_admins_row.id
      precedence = 2
    }
  ]
  destinations = [
    {
      type = "public"
      uri  = "opencode-rdp.${var.tld}"
    }
  ]
  target_criteria = [
    {
      port     = 3389
      protocol = "RDP"
      target_attributes = {
        hostname = ["TF-opencode-rdp"]
      }
    }
  ]
  app_launcher_visible = true
  logo_url             = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/opencode.png"
  depends_on = [cloudflare_zero_trust_access_infrastructure_target.lis_opencode_rdp]
}


resource "cloudflare_zero_trust_access_policy" "rdp_admins" {
  name             = "TF - RDP Admins - Portugal"
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

  connection_rules = {
    rdp = {
      allowed_clipboard_local_to_remote_formats = ["text"]
      allowed_clipboard_remote_to_local_formats = ["text"]
    }
  }
}

resource "cloudflare_zero_trust_access_policy" "rdp_admins_row" {
  name             = "TF - RDP Admins - RoW"
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
      group = {
        id = cloudflare_zero_trust_access_group.pocket_id_idps.id
      }
    }
  ]
  exclude = []

  connection_rules = {
    rdp = {
      allowed_clipboard_local_to_remote_formats = ["text"]
      allowed_clipboard_remote_to_local_formats = ["text"]
    }
  }
}
