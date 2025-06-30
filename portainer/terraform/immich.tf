resource "portainer_stack" "immich_stack" {
  name              = "immich"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/immich/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
