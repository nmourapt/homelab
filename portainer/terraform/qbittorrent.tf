resource "portainer_stack" "qbittorrent_stack" {
  name              = "qbittorrent"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/qbittorrent/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
