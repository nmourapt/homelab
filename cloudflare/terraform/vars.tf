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
}

variable "pocketid_client_id" {
  description = "Pocket ID OIDC client ID"
  type        = string
}

variable "pocketid_client_secret" {
  description = "Pocket ID OIDC client secret"
  type        = string
}