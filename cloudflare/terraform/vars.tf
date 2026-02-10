variable "cloudflare_api_token" {
  description = "API token for Cloudflare"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Cloudflare account email (for global API key auth)"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "Cloudflare Global API Key (not token)"
  type        = string
  sensitive   = true
}

variable "cloudflare_tld_zone_id" {
  description = "Cloudflare TLD Zone ID"
  type        = string
  sensitive   = true
}

variable "tld" {
  description = "Top Level Domain"
  type        = string
  sensitive   = true
}

variable "tld_alt" {
  description = "Alternative Top Level Domain"
  type        = string
  sensitive   = true
}

variable "pocketid_client_id" {
  description = "Pocket ID OIDC client ID"
  type        = string
}

variable "pocketid_client_secret" {
  description = "Pocket ID OIDC client secret"
  type        = string
  sensitive   = true
}

variable "pocketid_reauth_client_id" {
  description = "Pocket ID OIDC client ID for reauth"
  type        = string
}

variable "pocketid_reauth_client_secret" {
  description = "Pocket ID OIDC client secret for reauth"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
}

variable "google_workspace_client_id" {
  description = "Google Workspace OAuth client ID"
  type        = string
}

variable "google_workspace_client_secret" {
  description = "Google Workspace OAuth client secret"
  type        = string
  sensitive   = true
}

variable "egress_ips_json" {
  description = "JSON string of egress IPs list"
  type        = string
  sensitive   = true
}

variable "personal_emails_json" {
  description = "JSON string of personal emails list"
  type        = string
  sensitive   = true
}