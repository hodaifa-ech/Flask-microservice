
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" 
    }
  }

  
  backend "s3" {
    
    bucket         = "jenkins_bucket"
    key            = "jenkins-server/terraform.tfstate"       
    region         = "us-east-1"                               
    dynamodb_table = "terraform-state-lock-dynamo"            
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}