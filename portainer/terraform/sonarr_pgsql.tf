resource "portainer_stack" "sonarr_pgsql_stack" {
  name              = "sonarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/sonarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
