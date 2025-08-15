terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.9.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-ridwan"
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  # Configuration options
}