resource "portainer_stack" "booklore_mariadb_stack" {
  name              = "booklore_mariadb"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/booklore_mariadb/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_net]
}
