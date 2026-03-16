resource "cloudflare_zero_trust_device_managed_networks" "home" {
  account_id = var.cloudflare_account_id
  config = {
    tls_sockaddr = "192.168.1.254:443"
    sha256 = "9e960b77f6fbe0d32bdd97c073b7b2265c72c924143675cd718d7a0fc9d23758"
  }
  name = "home"
  type = "tls"
}