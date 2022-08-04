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

    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }

  }

  required_version = "~> 1.2.0"
}