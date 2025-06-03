
resource "portainer_docker_network" "prod_net" {
  endpoint_id = 1
  name        = "prod_net"
  driver      = "bridge"
  internal    = false
  attachable  = true
}
