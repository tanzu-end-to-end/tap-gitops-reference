provider "aws" {
  region = var.region
}

provider "tanzu-mission-control" {
  # Configuration options
  endpoint            = var.endpoint            # optionally use tanzu-mission-control_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_cloud_api_token # optionally use tanzu-mission-control_CSP_TOKEN env var
}