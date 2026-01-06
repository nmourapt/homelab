resource "portainer_stack" "upload-assistant_stack" {
  name              = "upload-assistant"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/upload-assistant/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
