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
