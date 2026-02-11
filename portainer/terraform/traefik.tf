resource "portainer_stack" "traefik_stack" {
  name              = "traefik"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/omni/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
