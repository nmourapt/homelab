resource "portainer_stack" "bazarr_pgsql_stack" {
  name              = "bazarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/bazarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
