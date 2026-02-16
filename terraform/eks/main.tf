# Optional: create new VPC (skip when use_existing_vpc = true to avoid VPC limit)
module "vpc" {
  count  = var.use_existing_vpc ? 0 : 1
  source = "./modules/vpc"

  name               = "${var.cluster_name}-vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  eks_cluster_name   = var.cluster_name
  enable_nat_gateway = true
}

locals {
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : module.vpc[0].vpc_id

  public_subnet_ids = (
    var.use_existing_vpc
      ? var.existing_public_subnet_ids
      : module.vpc[0].public_subnet_ids
  )

  private_subnet_ids = (
    var.use_existing_vpc
      ? var.existing_private_subnet_ids
      : module.vpc[0].private_subnet_ids
  )
}


# EKS cluster and node group (public subnets: internet access and reachable from internet)
module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  cluster_subnet_ids  = local.public_subnet_ids
  node_subnet_ids     = local.public_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  
  depends_on = [module.vpc]

  tags = {
    Environment = var.environment
  }
}
