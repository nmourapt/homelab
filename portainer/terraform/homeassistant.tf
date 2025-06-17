resource "portainer_stack" "homeassistant_stack" {
  name              = "homeassistant"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/homeassistant/docker-compose.yml"
  depends_on        = [portainer_docker_network.vlan101]
}
