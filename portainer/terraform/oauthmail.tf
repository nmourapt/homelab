resource "portainer_stack" "oauthmail_stack" {
  name              = "oauthmail"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/oauthmail/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
