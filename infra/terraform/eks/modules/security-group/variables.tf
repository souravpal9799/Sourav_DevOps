variable "name" {
  type        = string
  description = "Name of the security group"
}

variable "description" {
  type        = string
  default     = "Security group"
  description = "Description of the security group"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the security group will be created"
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    self        = optional(bool, false)
    description = optional(string, null)
  }))
  default     = []
  description = "List of ingress rules"
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
    description = optional(string, null)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }]
  description = "List of egress rules"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the security group"
}
