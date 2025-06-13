resource "portainer_stack" "radarr_pgsql_stack" {
  name              = "radarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/radarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
