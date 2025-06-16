resource "portainer_stack" "lidarr_pgsql_stack" {
  name              = "lidarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/lidarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
