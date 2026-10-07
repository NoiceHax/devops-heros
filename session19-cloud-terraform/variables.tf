variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "use_localstack" {
  description = "Point the AWS provider at LocalStack instead of real AWS."
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "LocalStack edge URL."
  type        = string
  default     = "http://localhost:4566"
}

variable "project" {
  description = "Name prefix for every resource."
  type        = string
  default     = "session19"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public subnet (must sit inside vpc_cidr)."
  type        = string
  default     = "10.20.1.0/24"
}

variable "ami_id" {
  description = "AMI for the EC2 instance (region specific, look one up for real AWS)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "bucket_name" {
  description = "S3 bucket name (globally unique on real AWS)."
  type        = string
}
