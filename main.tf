data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "web" {
  name        = "${var.app_name}-${var.environment}-web-sg"
  description = "Security group for ${var.app_name} web servers in ${var.environment}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidr
  }

  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-web-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  monitoring             = var.enable_detailed_monitoring
  vpc_security_group_ids = [aws_security_group.web.id]

  # Dynamically balance instances across available subnets
  subnet_id = element(data.aws_subnets.default.ids, count.index % length(data.aws_subnets.default.ids))

  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>Deployed via Terraform | Environment: ${var.environment} | Instance: ${count.index + 1}</h1>" > index.html
              python3 -m http.server 80 &
              EOF

  root_block_device {
    volume_size = var.environment == "prod" ? 50 : 20
    volume_type = "gp3"
    encrypted   = true
    tags = {
      Name        = "${var.app_name}-${var.environment}-root-${count.index + 1}"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-instance-${count.index + 1}"
    Environment = var.environment
    Workspace   = terraform.workspace
    Role        = "WebServer"
  }
}

resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}-assets"

  tags = {
    Name        = "${var.app_name}-${var.environment}-assets"
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "app_storage_versioning" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage_encryption" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
