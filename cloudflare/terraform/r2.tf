resource "cloudflare_r2_bucket" "omni_backups" {
  account_id = var.cloudflare_account_id
  name       = "omni-backups"
  location   = "WEUR"
}
