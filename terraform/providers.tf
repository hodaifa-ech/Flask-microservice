terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" 
    }
  }
  
  backend "s3" {
    bucket         = "flask_microservise12" 
    key            = "eks/microservices-app/terraform.tfstate"
    region         = "us-east-1" 
    dynamodb_table = "terraform-state-lock-dynamo" 
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}