# EKS Cluster (Terraform)

Terraform setup for an EKS cluster using **reusable modules** for network and security.

## Modules

| Module | Purpose |
|--------|--------|
| **modules/vpc** | Reusable EKS-ready VPC: public + private subnets, NAT gateway, EKS subnet tags |
| **modules/security-group** | Reusable security group with parameterized ingress/egress rules |
| **modules/eks** | EKS cluster + managed node group (IAM, control plane, nodes) |

## Quick start

1. Copy the example variables and set your region/AZs:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars: set availability_zones for your region
   ```

2. Configure AWS (profile or env vars):
   ```bash
   export AWS_PROFILE=your-profile
   # or export AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
   ```

3. Apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster_name>
   ```
   Or use the `configure_kubectl` output from `terraform output`.

## Reusing network and security groups

- **VPC**: Use `modules/vpc` from another root (e.g. another environment) by passing the same variables; set `eks_cluster_name` to tag subnets for EKS.
- **Security group**: Use `modules/security-group` with `ingress_rules` / `egress_rules` for ALB, bastion, or custom rules. An example is commented in `main.tf`.

## Inputs

See `variables.tf`. Key ones: `cluster_name`, `availability_zones`, `public_subnet_cidrs`, `private_subnet_cidrs`, `node_*` for node group sizing and instance types.
