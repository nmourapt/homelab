resource "portainer_stack" "mailcow_stack" {
  name              = "mailcow"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/mailcow/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
