
resource "portainer_stack" "vaultwarden_stack" {
  name              = "vaultwarden"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "./compose/vaultwarden.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
