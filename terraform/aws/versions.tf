terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.58"
    }
  }

  # Configure remote state before using in a team (recommended):
  # backend "s3" {
  #   bucket         = "predictmind-tfstate"
  #   key            = "aws/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "predictmind-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "PredictMind"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
