variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (e.g. dev, staging, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  default     = "1.30"
  description = "Kubernetes version for the EKS cluster"
}

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region (default: ap-south-1 Mumbai)"
}

variable "use_existing_vpc" {
  type        = bool
  default     = false
  description = "If true, use existing VPC and subnets instead of creating new ones (avoids VPC limit)"
}

variable "existing_vpc_id" {
  type        = string
  default     = ""
  description = "Existing VPC ID (required when use_existing_vpc = true)"
}

variable "existing_public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Existing public subnet IDs for EKS (required when use_existing_vpc = true; 2+ in different AZs)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC (used only when use_existing_vpc = false)"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
  description = "List of availability zone names (default: ap-south-1 Mumbai)"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "EC2 instance types for the EKS node group"
}

variable "node_desired_size" {
  type        = number
  default     = 2
  description = "Desired number of nodes in the node group"
}

variable "node_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of nodes"
}

variable "node_max_size" {
  type        = number
  default     = 4
  description = "Maximum number of nodes"
}
