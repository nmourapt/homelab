
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
  ipam = {
    driver = "default"
    config = [
      {
        subnet = "192.168.1.0/24"
        iprange = "192.168.1.64/27"
        gateway = "192.168.1.254"
      }
    ]
  }
}

resource "portainer_docker_network" "vlan1" {
  endpoint_id = 1
  name        = "vlan1"
  driver      = "macvlan"
  config_from = "vlan1config"
}


resource "portainer_docker_network" "vlan11config" {
  endpoint_id = 1
  name        = "vlan11config"
  driver      = "macvlan"
  config_only = true
  options = {
    parent = "eth0.11"
  }
}