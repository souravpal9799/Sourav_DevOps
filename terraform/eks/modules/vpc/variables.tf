variable "name" {
  type        = string
  description = "Name prefix for VPC and related resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zone names"
}

variable "eks_cluster_name" {
  type        = string
  default     = ""
  description = "EKS cluster name for subnet tags (optional; set for EKS subnet discovery)"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Create NAT gateway for private subnet internet access"
}
