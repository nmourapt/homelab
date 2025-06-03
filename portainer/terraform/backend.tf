
terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "portainer/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = { s3 = "https://d94d0ebef658cbd92166d633c8f065c9.r2.cloudflarestorage.com" }
  }
}