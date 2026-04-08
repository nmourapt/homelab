resource "portainer_stack" "nas_doctor_stack" {
  name              = "nas_doctor"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/nas_doctor/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
