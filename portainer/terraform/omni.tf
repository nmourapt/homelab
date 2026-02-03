resource "portainer_stack" "omni_stack" {
  name              = "omni"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/omni/docker-compose.yml"
}
