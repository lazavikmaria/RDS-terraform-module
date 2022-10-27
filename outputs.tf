output "rds_cluster_security_group_id" {
  description = "ID of the rds cluster security group."
  value       = aws_security_group.rds_sec_group.id
}

output "rds_cluster_security_group_arn" {
  description = "Arn of the rds cluster security group."
  value       = aws_security_group.rds_sec_group.arn
}

output "rds_cluster_db_subnet_group_id" {
  description = "ID of the rds cluster subnet group."
  value       = aws_db_subnet_group.default.id
}

output "rds_cluster_db_subnet_group_arn" {
  description = "Arn of the rds cluster subnet group."
  value       = aws_db_subnet_group.default.arn
}

output "rds_cluster_id" {
  description = "The RDS Cluster Identifier."
  value       = aws_rds_cluster.postgresql.id
}

output "rds_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = aws_rds_cluster.postgresql.arn
}

output "rds_cluster_write_endpoint" {
  description = "The DNS address of the RDS instance."
  value       = aws_rds_cluster.postgresql.endpoint
}

output "rds_cluster_read_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas."
  value       = aws_rds_cluster.postgresql.reader_endpoint
}

output "rds_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = aws_rds_cluster.postgresql.hosted_zone_id
}

output "rds_cluster_instance_id" {
  description = "The Instance identifier."
  value       = aws_rds_cluster_instance.cluster_instances.*.id
}

output "rds_cluster_instance_arn" {
  description = "Amazon Resource Name (ARN) of cluster instance."
  value       = aws_rds_cluster_instance.cluster_instances.*.arn
}

output "rds_cluster_parameter_group_id" {
  description = "The db cluster parameter group id."
  value       = try(aws_rds_cluster_parameter_group.rds_parameters[0].id, null)
}

output "rds_cluster_parameter_group_arn" {
  description = "The ARN of the db cluster parameter group."
  value       = try(aws_rds_cluster_parameter_group.rds_parameters[0].arn, null)
}
