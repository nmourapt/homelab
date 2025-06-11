resource "portainer_stack" "cloudflared_lis_prod_stack" {
  name              = "cloudflared_lis_prod"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/cloudflared_lis_prod/docker-compose.yml"
  depends_on        = [portainer_docker_network.prod_network]
}
