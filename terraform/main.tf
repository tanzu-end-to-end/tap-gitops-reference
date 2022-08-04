provider "aws" {
  region = var.region
}

provider "tanzu-mission-control" {
  # Configuration options
  endpoint            = var.endpoint
  vmw_cloud_api_token = var.vmw_cloud_api_token
}


//define in terraform.tfvars
//or set 
// # optionally use tanzu-mission-control_ENDPOINT env var
// # optionally use tanzu-mission-control_CSP_TOKEN env var

variable "endpoint" {
  # Configuration options
}
variable "vmw_cloud_api_token" {
  # Configuration options
}