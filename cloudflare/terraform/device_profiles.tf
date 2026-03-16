resource "cloudflare_zero_trust_device_custom_profile" "admins_mobile" {
  account_id = var.cloudflare_account_id
  name = "TF - Admins Mobile"
  precedence = 10

  match = "identity.groups.name == \"\\\"Administrators\\\"\" and os.name in {\"android\" \"ios\"}"

  enabled = true

  captive_portal = 180
  allow_mode_switch = true
  tunnel_protocol = "masque"
  switch_locked = false
  allowed_to_leave = true
  allow_updates = true
  auto_connect = 0
  support_url = "https://it.babybites.pt/help"
  service_mode_v2 = {
    mode = "warp"
  }
  exclude = [
    { address = "ff05::/16" },
    { address = "ff04::/16" },
    { address = "ff03::/16" },
    { address = "ff02::/16" },
    { address = "ff01::/16" },
    { address = "fe80::/10", description = "IPv6 Link Local" },
    { address = "fd00::/8" },
    { address = "10.0.0.0/8", description = "LAN" },
    { address = "172.16.0.0/12", description = "LAN" },
    { address = "192.168.0.0/16", description = "LAN" },
    { address = "100.96.0.0/11", description = "host selector routing" },
    { address = "100.88.0.0/13", description = "host selector routing" },
    { address = "100.84.0.0/14", description = "host selector routing" },
    { address = "100.82.0.0/15", description = "host selector routing" },
    { address = "100.81.0.0/16", description = "host selector routing" },
    { address = "100.64.0.0/12", description = "host selector routing" },
    { address = "192.0.0.0/24" },
    { address = "224.0.0.0/24" },
    { address = "240.0.0.0/4" },
    { address = "169.254.0.0/16", description = "DHCP Unspecified" },
    { address = "255.255.255.255/32", description = "DHCP Broadcast" },
  ]
  exclude_office_ips = false
  lan_allow_minutes = 10
  lan_allow_subnet_size = 24
  register_interface_ip_with_dns = true
  sccm_vpn_boundary_support = false
  # enable_netbt = false
}

resource "cloudflare_zero_trust_device_custom_profile_local_domain_fallback" "admins_mobile_local_domain_fallback" {
  account_id = var.cloudflare_account_id
  policy_id = cloudflare_zero_trust_device_custom_profile.admins_mobile.id
  domains = [
    { suffix = "intranet" },
    { suffix = "internal" },
    { suffix = "private" },
    { suffix = "localdomain" },
    { suffix = "domain" },
    { suffix = "lan" },
    { suffix = "home" },
    { suffix = "host" },
    { suffix = "corp" },
    { suffix = "local" },
    { suffix = "localhost" },
    { suffix = "invalid" },
    { suffix = "test" },
    { suffix = "lab" },
  ]
  depends_on = [cloudflare_zero_trust_device_custom_profile.admins_mobile]
}
