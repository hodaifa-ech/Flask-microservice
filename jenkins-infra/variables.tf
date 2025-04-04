variable "aws_region" {
  description = "AWS region to deploy Jenkins server."
  type        = string
  default     = "us-east-1"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins server."
  type        = string
  default     = "t3.medium" 
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the Jenkins instance. You need to create this in the AWS console beforehand."
  type        = string
  default     = "hodaifa" 
}

variable "allowed_ssh_cidr" {
  description = "List of CIDR blocks allowed for SSH access (port 22)."
  type        = list(string)
  default     = ["0.0.0.0/0"] 
}

variable "allowed_jenkins_ui_cidr" {
  description = "List of CIDR blocks allowed for Jenkins UI access (port 8080)."
  type        = list(string)
  default     = ["0.0.0.0/0"] 
}

variable "jenkins_server_name" {
  description = "Name tag for the Jenkins EC2 instance and related resources."
  type        = string
  default     = "JenkinsServer"
}

variable "jenkins_volume_size" {
  description = "Size of the root EBS volume for Jenkins in GB."
  type        = number
  default     = 30
}