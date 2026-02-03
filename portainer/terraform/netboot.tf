resource "portainer_stack" "netboot_stack" {
  name              = "netboot"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/netboot/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
