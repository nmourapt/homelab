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

variable "cloudflare_tld_zone_id" {
  description = "Cloudflare TLD Zone ID"
  type        = string
  sensitive   = true
}

variable "tld" {
  description = "Top Level Domain"
  type        = string
}