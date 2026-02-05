terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region = "ap-south-1"
}

# Generate SSH key locally before creating AWS key pair
resource "null_resource" "generate_ssh_key" {
  triggers = {
    script_hash = filesha256("${path.root}/scripts/gen_ssh_key.sh")
  }

  provisioner "local-exec" {
    command = "bash '${path.root}'/scripts/gen_ssh_key.sh"
  }
}
