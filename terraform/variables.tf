variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false //tmc doesn't allow uppers
}

variable "clusters" {
  description = "Array of cluster information"
  type = list(object({
    name        = string
    num_workers = number
  }))
  default = [
    {
      name        = "tap-view"
      num_workers = 3
    },
    {
      name        = "tap-iterate"
      num_workers = 3
    }

  ]
}


#####################################
# TMC configuration
#####################################
variable "cluster_group" {
  default     = "default"
  description = "The TMC cluster group to put the clusters"
}

data "aws_availability_zones" "available" {}


variable "vmw_cloud_endpoint" {
  default = "console.cloud.vmware.com"
}