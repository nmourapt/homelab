
terraform {
  required_providers {
    portainer = {
      source = "portainer/portainer"
      version = "~> 1.0"
    }
  }
}

provider "portainer" {
  endpoint = "https://portainer.nmoura.pt"
  api_key  = var.portainer_api_key
}
