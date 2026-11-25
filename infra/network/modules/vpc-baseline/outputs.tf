output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.private.id
}

output "security_group_id" {
  value = aws_security_group.baseline.id
}
