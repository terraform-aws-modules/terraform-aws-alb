terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.40"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
