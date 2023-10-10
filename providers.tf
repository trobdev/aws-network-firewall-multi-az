terraform {
  required_providers {
    aws = {
      version = "= 5.16.2"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
