output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ (for ALBs and the NAT gateway)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ (for compute and data stores)."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway the private subnets route through."
  value       = aws_nat_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table (default route to the internet gateway)."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table (default route to the NAT gateway)."
  value       = aws_route_table.private.id
}
