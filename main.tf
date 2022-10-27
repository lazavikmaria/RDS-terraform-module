data "aws_availability_zones" "available" {}

resource "random_password" "db_password" {
  length           = var.master_password_length
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = var.master_password_special
  special          = true
}

resource "aws_secretsmanager_secret" "secret_password" {
  name        = var.secretsmanager_password_secret_name
  description = "${var.cluster_instance_identifier} password secret."
}

resource "aws_secretsmanager_secret_version" "secret_password" {
  secret_id = aws_secretsmanager_secret.secret_password.id
  secret_string = jsonencode({
    engine   = "postgres",
    host     = aws_rds_cluster.postgresql.endpoint,
    ro-host  = aws_rds_cluster.postgresql.reader_endpoint,
    username = var.master_username,
    password = random_password.db_password.result,
    dbname   = var.db_name,
    port     = aws_rds_cluster.postgresql.port
  })
}

resource "null_resource" "az" {
  triggers = {
    names = join(",", slice(data.aws_availability_zones.available.names, 0, var.number_of_az))
  }
}

resource "aws_security_group" "rds_sec_group" {
  name        = lookup(var.rds_security_group, "name", null)
  vpc_id      = lookup(var.rds_security_group, "vpc_id", null)
  description = lookup(var.rds_security_group, "description", "RDS module security group")

  dynamic "ingress" {
    for_each = lookup(var.rds_security_group, "ingress_rules", {})

    content {
      description     = lookup(ingress.value, "description", null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      self            = lookup(ingress.value, "self", null)
      security_groups = lookup(ingress.value, "security_groups", [])
    }
  }

  dynamic "egress" {
    for_each = lookup(var.rds_security_group, "egress_rules", {})

    content {
      description     = lookup(egress.value, "description", null)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      self            = lookup(egress.value, "self", null)
      security_groups = lookup(egress.value, "security_groups", [])
    }
  }

  tags = lookup(var.rds_security_group, "tags", null)
}

resource "aws_db_subnet_group" "default" {
  name       = var.aws_db_subnet_group_name
  subnet_ids = var.private_subnet_ids

  tags = var.aws_db_subnet_group_tags
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier                  = var.rds_cluster_identifier
  engine                              = "aurora-postgresql"
  engine_version                      = var.engine_version
  availability_zones                  = split(",", null_resource.az.triggers.names)
  db_subnet_group_name                = aws_db_subnet_group.default.name
  database_name                       = var.db_name
  kms_key_id                          = var.cluster_kms_key
  storage_encrypted                   = var.cluster_storage_encrypted
  master_username                     = var.master_username
  master_password                     = random_password.db_password.result
  final_snapshot_identifier           = "${var.rds_cluster_identifier}-snapshot"
  skip_final_snapshot                 = var.skip_final_snapshot
  apply_immediately                   = true
  iam_database_authentication_enabled = true
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  copy_tags_to_snapshot               = true
  deletion_protection                 = var.deletion_protection
  allow_major_version_upgrade         = false
  enabled_cloudwatch_logs_exports     = var.cluster_cloudwatch_logs
  vpc_security_group_ids              = concat([aws_security_group.rds_sec_group.id], var.vpc_security_group_ids)
  db_cluster_parameter_group_name     = try(aws_rds_cluster_parameter_group.rds_parameters[0].name, null)
  tags                                = var.rds_cluster_tags

  depends_on = [
    aws_security_group.rds_sec_group,
    aws_rds_cluster_parameter_group.rds_parameters,
  ]

  lifecycle {
    ignore_changes = [
      availability_zones,
    ]
  }

}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count = var.cluster_instance_number

  identifier           = "${var.cluster_instance_identifier}-${count.index}"
  cluster_identifier   = aws_rds_cluster.postgresql.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.postgresql.engine
  engine_version       = aws_rds_cluster.postgresql.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.default.name
  monitoring_role_arn  = var.cluster_instance_monitoring_role_arn
  monitoring_interval  = var.cluster_instance_monitoring_interval

  tags = var.cluster_instance_tags
}

resource "aws_rds_cluster_parameter_group" "rds_parameters" {
  count = var.parameters_group != null ? 1 : 0

  name        = lookup(var.parameters_group, "name", null)
  family      = lookup(var.parameters_group, "family_group", "aurora-postgresql13")
  description = lookup(var.parameters_group, "description", "Managed by terraform.")

  dynamic "parameter" {
    for_each = var.parameters_group.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = lookup(var.parameters_group, "tags", null)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_role_association" "example" {
  count = var.roles_feature_names == {} ? 0 : length(var.roles_feature_names)

  db_cluster_identifier = aws_rds_cluster.postgresql.id
  feature_name          = element(values(var.roles_feature_names), count.index)
  role_arn              = element(keys(var.roles_feature_names), count.index)

  depends_on = [
    aws_rds_cluster_instance.cluster_instances
  ]
}
