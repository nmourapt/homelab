resource "portainer_stack" "postfix_stack" {
  name              = "postfix"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/postfix/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
