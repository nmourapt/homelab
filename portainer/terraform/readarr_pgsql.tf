resource "portainer_stack" "readarr_pgsql_stack" {
  name              = "readarr_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/readarr_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
