variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the cluster"
}

variable "cluster_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the EKS control plane (public + private; used for API and LBs)"
}

variable "node_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the node group (typically private only)"
}

variable "node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for the node group"
}

variable "node_desired_size" {
  type        = number
  default     = 2
  description = "Desired number of nodes"
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to EKS resources"
}
