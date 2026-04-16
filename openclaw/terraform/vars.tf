variable "oci_tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  sensitive   = true
}

variable "oci_user_ocid" {
  description = "OCI user OCID for API authentication"
  type        = string
  sensitive   = true
}

variable "oci_fingerprint" {
  description = "Fingerprint of the OCI API signing key"
  type        = string
  sensitive   = true
}

variable "oci_private_key" {
  description = "PEM-encoded private key for OCI API authentication"
  type        = string
  sensitive   = true
}

variable "oci_region" {
  description = "OCI region"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "oci_compartment_ocid" {
  description = "OCI compartment OCID (use tenancy OCID for free tier root compartment)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for the nuno user"
  type        = string
}

variable "cloudflared_token" {
  description = "Cloudflare Tunnel token for cloudflared service"
  type        = string
  sensitive   = true
}

variable "cloudflare_ca_pubkey" {
  description = "Cloudflare Access SSH CA public key for short-lived certificates"
  type        = string
  default     = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDaayQ7SCPxALzjnD9BFpS9yrDuJeqT38TR4llUompw86f3NmW1oIrMcUD04ilc4c8njr8TtT8GW70vKkK3FtGY= open-ssh-ca@cloudflareaccess.org"
}
