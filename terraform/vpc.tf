module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names 
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(var.vpc_cidr, 8, k)] 
  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(var.vpc_cidr, 8, k + length(data.aws_availability_zones.available.names))] 

  enable_nat_gateway = true 
  single_nat_gateway = true 
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }

  tags = {
    Project = "MicroservicesApp"
    Terraform = "true"
  }
}

data "aws_availability_zones" "available" {} 