data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh_http.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "tf-ubuntu22-web"
  }
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file("${path.root}/keys/terraform-key.pub")
  depends_on = [null_resource.generate_ssh_key]
}


