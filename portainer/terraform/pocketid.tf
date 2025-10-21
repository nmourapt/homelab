resource "portainer_stack" "pocketid_stack" {
  name              = "pocketid"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/pocketid/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
