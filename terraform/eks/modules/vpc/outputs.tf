output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_cidrs" {
  value = local.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = local.private_subnet_cidrs
}
