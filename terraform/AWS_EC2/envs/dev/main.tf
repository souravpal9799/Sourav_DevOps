module "vpc" {
  source      = "../../modules/vpc"
  name        = "dev-vpc"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

module "keypair" {
  source   = "../../modules/keypair"
  key_name = var.key_name
}

module "ec2" {
  source        = "../../modules/ec2"
  name          = "dev-ubuntu-ec2"
  instance_type = "t2.micro"

  subnet_id     = module.vpc.subnet_id
  vpc_id    = module.vpc.vpc_id
  
  key_name      = module.keypair.key_name
}
