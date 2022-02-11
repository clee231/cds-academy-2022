terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }

  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage

# Use environment variables to define the access_key and secret_key.
# export AWS_ACCESS_KEY_ID="<your_key>"
# export AWS_SECRET_ACCESS_KEY="<your_key>"
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

# https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
provider "http" {
  # Configuration options
}


