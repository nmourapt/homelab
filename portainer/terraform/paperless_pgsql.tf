resource "portainer_stack" "paperless_pgsql_stack" {
  name              = "paperless_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/paperless_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
