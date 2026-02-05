module "vpc" {
  source      = "../../modules/vpc"
  cidr_block  = "10.0.0.0/16"
  name        = "dev-vpc"
  environment = "dev"
}

module "subnet" {
  source      = "../../modules/subnet"
  vpc_id      = module.vpc.vpc_id
  cidr_block  = "10.0.1.0/24"
  az          = "ap-south-1a"
  name        = "dev-subnet"
  environment = "dev"
}

module "k8s_master" {
  source              = "../../modules/ec2"
  ami                 = var.ami
  instance_type       = "t3.medium"
  subnet_id           = module.subnet.subnet_id
  security_group_ids  = [aws_security_group.k8s.id]
  key_name            = var.key_name
  user_data           = file("../../scripts/k8s-master.sh")
  name                = "k8s-master"
  role                = "master"
  environment         = "dev"
}

module "k8s_worker" {
  source              = "../../modules/ec2"
  ami                 = var.ami
  instance_type       = "t3.medium"
  subnet_id           = module.subnet.subnet_id
  security_group_ids  = [aws_security_group.k8s.id]
  key_name            = var.key_name
  user_data           = file("../../scripts/k8s-worker.sh")
  name                = "k8s-worker"
  role                = "worker"
  environment         = "dev"
}
