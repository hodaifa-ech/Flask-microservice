
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"] 
  }
  tags = {
    Tier = "Public" 
  }
}


data "aws_iam_policy_document" "jenkins_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins_role" {
  name               = "${var.jenkins_server_name}-Role"
  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role_policy.json
  tags = {
    Name    = "${var.jenkins_server_name}-Role"
    Project = "DevOps-Microservices-Practice"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_cluster" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" 
}


resource "aws_iam_role_policy_attachment" "jenkins_eks_service" {
   role       = aws_iam_role.jenkins_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
resource "aws_iam_role_policy_attachment" "jenkins_eks_vpc_resource_controller" {
   role       = aws_iam_role.jenkins_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" 
}

resource "aws_iam_role_policy_attachment" "jenkins_vpc" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}


resource "aws_iam_role_policy_attachment" "jenkins_s3" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "jenkins_dynamodb" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" 
}

resource "aws_iam_role_policy_attachment" "jenkins_iam" {
   role       = aws_iam_role.jenkins_role.name
   policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess" 
}

resource "aws_iam_role_policy_attachment" "jenkins_cfn" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.jenkins_server_name}-InstanceProfile"
  role = aws_iam_role.jenkins_role.name
  tags = {
    Name    = "${var.jenkins_server_name}-InstanceProfile"
    Project = "DevOps-Microservices-Practice"
  }
}


resource "aws_security_group" "jenkins_sg" {
  name        = "${var.jenkins_server_name}-SG"
  description = "Allow SSH and Jenkins UI access"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "Allow SSH from specified CIDRs"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_jenkins_ui_cidr
    description = "Allow Jenkins UI from specified CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.jenkins_server_name}-SG"
    Project = "DevOps-Microservices-Practice"
  }
}



resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
 
  subnet_id              = data.aws_subnets.public.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name
  user_data              = file("${path.module}/user_data.sh")

  associate_public_ip_address = true 

  root_block_device {
    volume_size = var.jenkins_volume_size
    volume_type = "gp3" 
    delete_on_termination = true 
  }

  tags = {
    Name    = var.jenkins_server_name
    Project = "DevOps-Microservices-Practice"
  }

  depends_on = [aws_iam_instance_profile.jenkins_instance_profile]
}