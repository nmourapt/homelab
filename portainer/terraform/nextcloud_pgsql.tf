resource "portainer_stack" "nextcloud_pgsql_stack" {
  name              = "nextcloud_pgsql"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/nextcloud_pgsql/docker-compose.yml"
  depends_on        = [portainer_docker_network.vlan101]
}
