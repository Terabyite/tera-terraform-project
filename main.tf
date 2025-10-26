# VPC
resource "aws_vpc" "TeraVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "TeraVPC"
  }
}

# Subnets
resource "aws_subnet" "TeraPublicSubnet" {
  vpc_id                  = aws_vpc.TeraVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "TeraPublicSubnet"
  }
}

resource "aws_subnet" "TeraPrivateSubnet" {
  vpc_id            = aws_vpc.TeraVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "TeraPrivateSubnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "TeraIGW" {
  vpc_id = aws_vpc.TeraVPC.id
  tags = {
    Name = "TeraIGW"
  }
}

# Route Table
resource "aws_route_table" "TeraPublicRouteTable" {
  vpc_id = aws_vpc.TeraVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TeraIGW.id
  }
  tags = {
    Name = "TeraPublicRouteTable"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "TeraPublicRouteTableAssoc" {
  subnet_id      = aws_subnet.TeraPublicSubnet.id
  route_table_id = aws_route_table.TeraPublicRouteTable.id
}

# Security Group
resource "aws_security_group" "TeraSecurityGroup" {
  name        = "TeraSecurityGroup"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.TeraVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TeraSecurityGroup"
  }
}

# IAM Role
resource "aws_iam_role" "TeraEC2Role" {
  name = "TeraEC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "TeraEC2Attach" {
  role       = aws_iam_role.TeraEC2Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "TeraInstanceProfile" {
  name = "TeraInstanceProfile"
  role = aws_iam_role.TeraEC2Role.name
}

# EC2 Instance
resource "aws_instance" "TeraInstance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.TeraPublicSubnet.id
  vpc_security_group_ids = [aws_security_group.TeraSecurityGroup.id]
  iam_instance_profile   = aws_iam_instance_profile.TeraInstanceProfile.name
  key_name               = var.key_name

  tags = {
    Name = "TeraInstance"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "TeraBucket" {
  bucket = "tera-bucket-${var.user_suffix}"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "TeraBucket"
  }
}