data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_tenancy_ocid
}

data "oci_core_images" "ubuntu_aarch64" {
  compartment_id           = var.oci_compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "cloudinit_config" "openclaw" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_public_key        = var.ssh_public_key
      cloudflared_token     = var.cloudflared_token
      cloudflare_ca_pubkey  = var.cloudflare_ca_pubkey
    })
  }
}

resource "oci_core_instance" "openclaw" {
  compartment_id      = var.oci_compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "openclaw"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_aarch64.images[0].id
    boot_volume_size_in_gbs = 100
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    display_name     = "openclaw-vnic"
    hostname_label   = "openclaw"
  }

  metadata = {
    user_data = data.cloudinit_config.openclaw.rendered
  }

  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      metadata,
    ]
  }
}
