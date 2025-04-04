module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.23" 

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets 

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64" 
  }

  eks_managed_node_groups = {
    
    general = {
      min_size     = 1
      max_size     = 3
      desired_size = var.desired_node_count

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND" 
    }
  }

  cluster_endpoint_public_access = true 

 
  tags = {
    Project = "MicroservicesApp"
    Terraform = "true"
  }
}