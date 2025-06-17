
resource "portainer_docker_network" "prod_net" {
  endpoint_id = 1
  name        = "prod_net"
  driver      = "bridge"
  internal    = false
  attachable  = true
  enable_ipv4 = true
  scope       = "local"
  ipam_driver = "default"
  ipam_config {
    subnet    = "192.168.255.0/24"
    gateway   = "192.168.255.254"
    ip_range  = "192.168.255.64/27"
  }
}


resource "portainer_docker_network" "vlan101config" {
  endpoint_id = 1
  name        = "vlan101config"
  driver      = "macvlan"
  config_only = true
  enable_ipv4 = true
  options = {
    parent = "eth0.101"
  }
  ipam_driver = "default"
  ipam_config {
    subnet    = "192.168.101.0/24"
    gateway   = "192.168.101.254"
    ip_range  = "192.168.101.64/27"
  }
}

resource "portainer_docker_network" "vlan101" {
  endpoint_id = 1
  name        = "vlan101"
  driver      = "macvlan"
  config_from = "vlan101config"
  depends_on  = [portainer_docker_network.vlan101config]
}


resource "portainer_docker_network" "vlan1config" {
  endpoint_id = 1
  name        = "vlan1config"
  driver      = "macvlan"
  config_only = true
  enable_ipv4 = true
  options = {
    parent = "eth0.1"
  }
  ipam_driver = "default"
  ipam_config {
    subnet    = "192.168.1.0/24"
    gateway   = "192.168.1.254"
    ip_range  = "192.168.1.64/27"
  }
}

resource "portainer_docker_network" "vlan1" {
  endpoint_id = 1
  name        = "vlan1"
  driver      = "macvlan"
  config_from = "vlan1config"
  depends_on  = [portainer_docker_network.vlan1config]
}
