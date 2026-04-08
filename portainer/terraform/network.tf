
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


resource "portainer_docker_network" "vlan101" {
  endpoint_id = 1
  name        = "vlan101"
  driver      = "macvlan"
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


resource "portainer_docker_network" "vlan1" {
  endpoint_id = 1
  name        = "vlan1"
  driver      = "macvlan"
  options = {
    parent = "eth0.1"
  }
  ipam_driver = "default"
  ipam_config {
    subnet    = "192.168.111.0/24"
    gateway   = "192.168.111.254"
    ip_range  = "192.168.111.64/27"
  }
}
