variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  default     = "ami-07860a2d7eb515d9a"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Your AWS EC2 key pair name"
  default     = "mytraining"
}

variable "user_suffix" {
  description = "Unique suffix for bucket naming"
  default     = "terauser123"
}