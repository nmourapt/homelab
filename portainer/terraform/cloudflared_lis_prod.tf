
resource "portainer_stack" "cloudflared_lis_prod_stack" {
  name              = "cloudflared_lis_prod"
  deployment_type   = "standalone"
  method            = "file"
  endpoint_id       = 1
  stack_file_path   = "./compose/cloudflared_lis_prod.yml"
}
