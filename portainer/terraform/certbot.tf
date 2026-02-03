resource "portainer_stack" "certbot_stack" {
  name              = "certbot"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/certbot/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
