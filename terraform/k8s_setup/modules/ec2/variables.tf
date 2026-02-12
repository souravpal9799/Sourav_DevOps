variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssh_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "sg_name" {
  type    = string
}