resource "portainer_stack" "vaultwarden_stack" {
  name                      = "vaultwarden"
  deployment_type           = "standalone"
  method                    = "repository"
  endpoint_id               = 1
  repository_url            = "https://github.com/nmourapt/homelab/"
  repository_reference_name = "refs/heads/main"
  file_path_in_repository   = "/portainer/stacks/vaultwarden/docker-compose.yml"
  stack_webhook             = true
}

output "vaultwarden_webhook" {
  description = "GitOps Vaultwarden stack webhook URL"
  value       = portainer_stack.vaultwarden_stack.webhook_url
}