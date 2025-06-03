variable "vaultwarden_admin_token" {
  description = "Admin token for Vaultwarden"
  type        = string
  sensitive   = true
}

variable "vaultwarden_domain" {
  description = "Domain for Vaultwarden"
  type        = string
  sensitive   = true
}

resource "portainer_stack" "vaultwarden_stack" {
  name              = "vaultwarden"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "./compose/vaultwarden.yml"

}
