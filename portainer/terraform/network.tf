resource "portainer_docker_network" "prod_network" {
  endpoint_id = 1
  name        = "prod_network"
  driver      = "bridge"
  internal    = false
  attachable  = true
  enable_ipv4 = true
  scope       = "local"
}

resource "portainer_docker_network" "prod_net" {
  endpoint_id = 1
  name        = "prod_net"
  driver      = "bridge"
  internal    = false
  attachable  = true
  enable_ipv4 = true
  scope       = "local"
}

resource "portainer_docker_network" "vlan111config" {
  endpoint_id = 1
  name        = "vlan111config"
  driver      = "macvlan"
  config_only = true
  enable_ipv4 = true
  options = {
    parent = "eth0.111"
  }
  ipam_driver = "default"
  ipam_config {
    subnet    = "192.168.111.0/24"
    gateway   = "192.168.111.254"
    ip_range  = "192.168.111.64/27"
  }
}

resource "portainer_docker_network" "vlan111" {
  endpoint_id = 1
  name        = "vlan111"
  driver      = "macvlan"
  config_from = "vlan111config"
  depends_on        = [portainer_docker_network.vlan111config]
}
