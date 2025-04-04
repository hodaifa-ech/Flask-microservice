#!/bin/bash
# User data script to set up Jenkins and necessary tools on Amazon Linux 2
# Run as root

set -e # Exit immediately if a command exits with a non-zero status.

# 1. System Updates and Base Packages
echo "Updating system packages..."
yum update -y

echo "Installing base packages (Java, Git, unzip)..."
amazon-linux-extras install java-openjdk11 -y # Jenkins requires Java
yum install git unzip -y

# 2. Install Jenkins
echo "Installing Jenkins..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y
# Jenkins service will be enabled and started later

# 3. Install Docker
echo "Installing Docker..."
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Add jenkins user to docker group (requires Jenkins restart later)
usermod -a -G docker jenkins
echo "Added jenkins user to docker group. Jenkins service needs restart after setup."

# 4. Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip # Cleanup
echo "AWS CLI version:"
aws --version

# 5. Install kubectl (Match version roughly with your intended EKS version)
echo "Installing kubectl..."
# Find latest stable version or specify one: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
KUBECTL_VERSION="v1.23.17" # Example: Choose a version compatible with your planned EKS cluster
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/2023-03-17/bin/linux/amd64/kubectl
# Example for latest: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
echo "kubectl version:"
kubectl version --client

# 6. Install Terraform
echo "Installing Terraform..."
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform
echo "Terraform version:"
terraform version

# 7. Install Ansible
echo "Installing Ansible..."
amazon-linux-extras install epel -y # Ansible often needs EPEL repository
yum install ansible -y
echo "Ansible version:"
ansible --version

# 8. Start Jenkins
echo "Enabling and starting Jenkins..."
systemctl enable jenkins
systemctl start jenkins

# 9. Output Initial Admin Password Location (useful for first login)
echo "Jenkins initial admin password can be found in /var/lib/jenkins/secrets/initialAdminPassword"
echo "Wait a few minutes for Jenkins to start..."
# Wait a bit for Jenkins to potentially write the password file
sleep 60
echo "Attempting to display initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Could not read initial password yet. Check the file manually after SSHing in."


echo "-----------------------------------------------------"
echo "Setup Complete!"
echo "Access Jenkins at http://PUBLIC_IP:8080" # Placeholder, actual IP will be output by Terraform
echo "Use SSH key to connect: ssh -i your-key.pem ec2-user@PUBLIC_IP" # Placeholder
echo "Initial admin password is in /var/lib/jenkins/secrets/initialAdminPassword"
echo "Remember to restart Jenkins service if docker commands fail for jenkins user:"
echo "sudo systemctl restart jenkins"
echo "-----------------------------------------------------"