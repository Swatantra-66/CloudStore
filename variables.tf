variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Target environment name (dev or prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "app_name" {
  description = "Name of the application or workload"
  type        = string
  default     = "cloudstore"
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro for dev, t3.small for prod)"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "enable_detailed_monitoring" {
  description = "Flag to enable detailed CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "allowed_http_cidr" {
  description = "Allowed CIDR blocks for incoming HTTP traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

