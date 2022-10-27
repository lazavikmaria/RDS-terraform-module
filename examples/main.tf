locals {
  rds_cluster_identifier = "rds-psql-cluster"
  vpc_id                 = "vpc-XXXXXXXXXXXXXXXX"
  role_for_rds           = "mock_arn_role"
}

module "trm-rds-module" {
  source = "../"

  ### --- Common variables --- ###
  vpc_id       = local.vpc_id
  number_of_az = "2"
  private_subnet_ids = [
    "subnet-11111111111111111",
    "subnet-22222222222222222"
  ]

  rds_security_group = {
    name        = local.rds_cluster_identifier
    vpc_id      = local.vpc_id
    description = "Allow trafic to/from RDS."

    ingress_rules = [{
      description = "Allow traffic to RDS."
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]

    egress_rules = [{
      description = "Outcoming traffic from RDS."
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]

    tags = {
      Name = "${local.rds_cluster_identifier}-sg"
    }
  }

  aws_db_subnet_group_tags = {
    Name = "DB-SG-TAG-NAME"
  }

  ### --- Cluster variables --- ###
  rds_cluster_identifier      = local.rds_cluster_identifier
  cluster_instance_identifier = local.rds_cluster_identifier
  cluster_instance_number     = "2"
  instance_class              = "db.r5.large"
  # cluster_storage_encrypted = true
  db_name                             = "deleteDB"
  secretsmanager_password_secret_name = "database_password"
  rds_cluster_tags = {
    Name = "SUPER-RDS-CLUSTER-NAME"
  }

  ## --- Parameter group variables --- ###
  parameters_group = {
    name                                        = local.rds_cluster_identifier
    aws_rds_cluster_parameter_group_description = "DB cluster parameter group. Managed by terraform."
    parameters = [
      {
        name  = "rds.force_ssl"
        value = "1"
      }
    ]
  }

  roles_feature_names = {
    local.role_for_rds = "s3Export"
  }

  ### --- Providers variables --- ###
  aws_region          = "us-east-2"
  owner               = ""
  value_stream        = ""
  product             = ""
  component           = ""
  environment         = "Personal"
  data_classification = "Internal"
  created_using       = "Terraform"
}

output "cluster_write_endpoint" {
  value = module.trm-rds-module.rds_cluster_write_endpoint
}

output "cluster_read_endpoint" {
  value = module.trm-rds-module.rds_cluster_read_endpoint
}

output "rds_cluster_parameter_group_id" {
  value = module.trm-rds-module.rds_cluster_parameter_group_id
}

output "rds_cluster_parameter_group_arn" {
  value = module.trm-rds-module.rds_cluster_parameter_group_arn
}
