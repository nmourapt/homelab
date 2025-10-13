resource "portainer_stack" "plex_stack" {
  name              = "plex"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/plex/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
