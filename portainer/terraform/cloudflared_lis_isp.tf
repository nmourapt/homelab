resource "portainer_stack" "cloudflared_lis_isp_stack" {
  name              = "cloudflared_lis_isp"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "../stacks/cloudflared_lis_isp/docker-compose.yml"
}
