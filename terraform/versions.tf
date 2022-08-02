terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24.0"
    }

    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.0.3"
    }

  }

  required_version = "~> 1.2.0"
}