resource "cloudflare_zero_trust_list" "egress_ips" {
  account_id  = var.cloudflare_account_id
  name        = "TF - Egress IPs"
  type        = "IP"
  description = "ZT Egress IPs"
  items       = jsondecode(var.egress_ips_json)
}

resource "cloudflare_zero_trust_list" "home_ip" {
  account_id  = var.cloudflare_account_id
  name        = "TF - Home IP"
  type        = "IP"
  description = "Home IP"
}

resource "cloudflare_zero_trust_list" "personal_emails" {
  account_id  = var.cloudflare_account_id
  name        = "TF - Personal Emails"
  type        = "EMAIL"
  description = "Personal Emails"
  items       = jsondecode(var.personal_emails_json)
}