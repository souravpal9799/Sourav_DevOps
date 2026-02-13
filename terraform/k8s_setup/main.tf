module "vpc" {
  source      = "./modules/vpc"
  name        = "dev-vpc"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
}

module "keypair" {
  source   = "./modules/keypair"
  key_name = var.key_name
}

module "sg" {
  source  = "./modules/security-group"
  sg_name = "k8s-sg"
  vpc_id  = module.vpc.vpc_id
}

module "master" {
  source        = "./modules/ec2"
  name          = "kube-master"
  instance_type = "t2.micro"

  subnet_id  = module.vpc.subnet_id
  vpc_id     = module.vpc.vpc_id
  sg_name    = [module.sg.sg_id]

  key_name   = module.keypair.key_name
  user_data  = file("userdata/master.sh")
}

module "worker" {
  source        = "./modules/ec2"
  name          = "kube-worker"
  instance_type = "t2.micro"

  subnet_id  = module.vpc.subnet_id
  vpc_id     = module.vpc.vpc_id
  sg_name    = [module.sg.sg_id]

  key_name   = module.keypair.key_name
  user_data  = file("userdata/worker.sh")
}