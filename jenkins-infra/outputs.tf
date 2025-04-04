output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance."
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of the Jenkins EC2 instance."
  value       = aws_instance.jenkins_server.public_dns
}

output "jenkins_ui_url" {
  description = "URL to access the Jenkins UI."
  value       = "http://${aws_instance.jenkins_server.public_dns}:8080"
}

output "ssh_command" {
  description = "Command to SSH into the Jenkins server (replace 'your-key.pem' with your actual key file)."
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.jenkins_server.public_dns}"
}

output "initial_admin_password_command" {
  description = "Command to retrieve the initial Jenkins admin password via SSH."
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.jenkins_server.public_dns} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "jenkins_instance_id" {
    description = "ID of the Jenkins EC2 instance."
    value = aws_instance.jenkins_server.id
}