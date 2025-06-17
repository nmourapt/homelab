resource "portainer_stack" "bazarr_pgsq_stack" {
  name              = "bazarr_pgsq"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/bazarr_pgsq/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
