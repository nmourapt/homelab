
resource "portainer_docker_network" "prod_network" {
  endpoint_id = 1
  name        = "prod_network"
  driver      = "bridge"
  internal    = false
  attachable  = true
}

resource "portainer_docker_network" "vlan1_config" {
  endpoint_id = 1
  name        = "vlan1_config"
  driver      = "macvlan"
  config_only = true
  options = {
    parent = "eth0.1"
  }
}