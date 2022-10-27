# rds

TRM Terraform repository for RDS module.

  - [Tested on](#tested-on)
  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Provider Inputs](#provider-inputs)
  - [Outputs](#outputs)
  - [Examples](#examples)
    - [Example of variables](#example-of-variables)

## Tested on

| Name         | Version |
| ------------ | ------- |
| terraform    | 1.1.7   |
| terragrunt   | 0.35.x  |
| aws_provider | 4.17    |

## Usage

```hcl
locals {
  rds_cluster_identifier = "rds-psql-cluster"
  vpc_id                 = "vpc-XXXXXXXXXXXXXXXX"
  role_for_rds           = "mock_arn_role"

}

module "trm-rds-module" {
  source = "./"

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
  rds_cluster_identifier  = local.rds_cluster_identifier
  cluster_instance_identifier =- local.rds_cluster_identifier
  cluster_instance_number = "2"
  instance_class          = "db.r5.large"
  cluster_storage_encrypted = true
  db_name         = "deleteDB"
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| **vpc_id** | VPC ID. | `string` |  | yes |
| **private_subnet_ids** | Private subnet IDs. | `list(string)` |  | yes |
| **number_of_az** | Number of Availability zones. | `string` | `"2"` | no |
| **rds_security_group** | A list of maps containing key/value pairs that define the rds security group to be created. | `any` | `[]` | yes |
| **aws_db_subnet_group_name** | The name of the DB subnet group. | `string` | `"rds-subnet-group-name"` | no |
| **aws_db_subnet_group_tags** | Tags for the DB subnet group | `map(string)` | `null` | no |
| **rds_cluster_identifier** | The cluster identifier. | `string` |  | yes |
| **master_password_length** | The length of the string desired. | `number` | `16` | no |
| **master_password_special** | Supply your own list of special characters to use for string generation. | `string` | `"!#*()-_=[]{}<>:?"` | no |
| **secretsmanager_password_secret_name** | The name of the database password secret to retrieve from the AWS Secrets Manager. | `string` |  | yes |
| **engine_version** | Database engine version. | `string` | `"13.4"` | no |
| **db_name** | DB name. | `string` |  | yes |
| **roles_feature_names** | A map of ARNs for the IAM roles to associate to the RDS Cluster and name of the feature for association | `map(string)` | `{}` | no |
| **cluster_kms_key** | The ARN for the KMS encryption key. | `string` | `null` | no |
| **cluster_storage_encrypted** | Specifies whether the DB cluster is encrypted. | `bool` | `false` | no |
| **master_username** | Username for the master DB user. | `string` | `"postgres"` | no |
| **skip_final_snapshot** | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. | `string` | `"false"` | no |
| **backup_retention_period** | The backup retention period. Retention period must be between 1 and 35 | `string` | `"1"` | no |
| **preferred_backup_window** | The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00 | `string` | `""` | no |
| **deletion_protection** | The database can't be deleted when this value is set to true. | `string` | `"false"` | no |
| **cluster_cloudwatch_logs** | Set of log types to export to cloudwatch. Types are supported: audit, error, general, slowquery, postgresql. | `list(any)` | `["postgresql"]` | no |
| **vpc_security_group_ids** | List of VPC security groups to associate with the Cluster. | `list(string)` | `[]` | no |
| **rds_cluster_tags** | Tags for the aws_rds_cluster. | `map(string)` | `null` | no |
| **cluster_instance_identifier** | The identifier for the RDS cluster instance. | `map(string)` | `"trm-rds-instance-identifier"` | no |
| **instance_class** | The instance class to use. | `string` | `"db.r5.large"` | no |
| **cluster_instance_number** | umber of clister instance. | `string` | `"2"` | no |
| **cluster_instance_tags** | Tags for the aws rds cluster instances. | `string` | `"trm-aurora-psql-cluster"` | no |
| **cluster_instance_monitoring_role_arn** | "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. | `string` | `null` | no |
| **cluster_instance_monitoring_interval** | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. | `number` | `0` | no |
| **parameters_group** | Set of aws_rds_cluster_parameter_group options. | `any` | `null` | no |

## Provider Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| **aws_region** | The AWS region to use for provisioning | `string` |  | yes |
| **owner** | The group that supports the environment | `string` |  | yes |
| **value_stream** | The name of the Stream (e.g. Information Technology) | `string` |  | yes |
| **product** | High level product that is sold to customers or used internally. | `string` |  | yes |
| **component** | The name of the system components | `string` |  | yes |
| **environment** | Specifies the current environment | `string` |  | yes |
| **data_classification** | Type of data confidentiality | `string` |  | yes |
| **created_using** | Tool that was used to create the application | `string` | `"Terraform"` | no |
| **source_code** | The location of the source code for creating this resource | `string` | `"trm-infra-rds"` | no |

## Outputs

| Name                            | Description                                                                               |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| rds_cluster_security_group_id   | ID of the rds cluster security group.                                                     |
| rds_cluster_security_group_arn  | Arn of the rds cluster security group.                                                    |
| rds_cluster_db_subnet_group_id  | ID of the rds cluster subnet group.                                                       |
| rds_cluster_db_subnet_group_arn | Arn of the rds cluster subnet group.                                                      |
| rds_cluster_id                  | The RDS Cluster Identifier.                                                               |
| rds_cluster_arn                 | Amazon Resource Name (ARN) of cluster.                                                    |
| rds_cluster_write_endpoint      | The DNS address of the RDS instance.                                                      |
| rds_cluster_read_endpoint       | A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas. |
| rds_cluster_hosted_zone_id      | The Route53 Hosted Zone ID of the endpoint.                                               |
| rds_cluster_instance_arn        | Amazon Resource Name (ARN) of cluster instance.                                           |
| rds_cluster_instance_id         | The Instance identifier.                                                                  |
| rds_cluster_parameter_group_id  | The db cluster parameter group id.                                                        |
| rds_cluster_parameter_group_arn | The ARN of the db cluster parameter group.                                                |


### Example of variables

```hcl
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
```

```hcl
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
```
