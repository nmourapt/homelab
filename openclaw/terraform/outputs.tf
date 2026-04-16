output "instance_private_ip" {
  description = "Private IP of the openclaw instance"
  value       = oci_core_instance.openclaw.private_ip
}

output "instance_id" {
  description = "OCID of the openclaw instance"
  value       = oci_core_instance.openclaw.id
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.openclaw.id
}

output "subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private.id
}
