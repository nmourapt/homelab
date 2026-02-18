resource "portainer_stack" "seerr_pgsql_stack" {
  name              = "seerr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/seerr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
