
resource "portainer_docker_network" "prod_network" {
  endpoint_id = 1
  name        = "prod_network"
  driver      = "bridge"
  internal    = false
  attachable  = true
}

resource "portainer_docker_network" "vlan1config" {
  endpoint_id = 1
  name        = "vlan1config"
  driver      = "macvlan"
  config_only = true
  options = {
    parent = "eth0.1"
  }
}

resource "portainer_docker_network" "vlan1" {
  endpoint_id = 1
  name        = "vlan1"
  driver      = "macvlan"
  config_only = true
  config_from = {
    network = "vlan1config"
  }
}