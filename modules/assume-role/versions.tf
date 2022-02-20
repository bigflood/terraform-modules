terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.35"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }
  }
}
