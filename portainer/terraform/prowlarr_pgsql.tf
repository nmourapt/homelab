resource "portainer_stack" "prowlarr_pgsql_stack" {
  name              = "prowlarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/prowlarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
