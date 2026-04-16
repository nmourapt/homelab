resource "oci_core_vcn" "openclaw" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "openclaw-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "openclaw"
}

resource "oci_core_internet_gateway" "openclaw" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "openclaw-igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "openclaw" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "openclaw-natgw"
}

resource "oci_core_route_table" "private" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "openclaw-private-rt"

  route_rules {
    network_entity_id = oci_core_nat_gateway.openclaw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.oci_compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "openclaw-private-sl"

  # Allow all egress (needed for cloudflared, apt, etc.)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  # Allow all traffic within VCN
  ingress_security_rules {
    protocol  = "all"
    source    = "10.0.0.0/16"
    stateless = false
  }
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.oci_compartment_ocid
  vcn_id                     = oci_core_vcn.openclaw.id
  display_name               = "openclaw-private-subnet"
  cidr_block                 = "10.0.1.0/24"
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
}
