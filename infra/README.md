Infra - Terraform and Cloud Resources

Responsibility:
- Hold Terraform modules and environment-level IaC that provision cloud resources required by the platform: VPC, EKS clusters, IAM roles, S3 buckets, and remote state configuration.
- Provide documented, parameterized modules and remote state guidance (S3 + DynamoDB or equivalent) to prevent state drift and enable safe, CI-driven applies.

Contents (recommended):
- `terraform/eks` – EKS module and example environment configs
- `state/` – terraform remote state bootstrap scripts and locking guidance

Operational notes:
- Never commit `*.tfstate` or `.terraform` directories. Use remote state and CI gates for production changes.
