variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name for the EKS cluster."
  type        = string
  default     = "microservices-app-eks"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_types" {
  description = "Instance types for EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"] 
}

variable "desired_node_count" {
    description = "Desired number of worker nodes."
    type = number
    default = 2
}