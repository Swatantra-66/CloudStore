output "active_workspace" {
  description = "Active Terraform workspace"
  value       = terraform.workspace
}

output "environment" {
  description = "Target environment name"
  value       = var.environment
}

output "vpc_id_discovered" {
  description = "Default VPC ID dynamically discovered by data block"
  value       = data.aws_vpc.default.id
}

output "available_subnets_count" {
  description = "Number of subnets dynamically discovered"
  value       = length(data.aws_subnets.default.ids)
}

output "selected_ami_id" {
  description = "AMI ID dynamically fetched for Amazon Linux 2023"
  value       = data.aws_ami.amazon_linux.id
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_types" {
  description = "Types of launched EC2 instances"
  value       = aws_instance.web[*].instance_type
}

output "s3_bucket_name" {
  description = "Name of the created S3 storage bucket"
  value       = aws_s3_bucket.app_storage.id
}
