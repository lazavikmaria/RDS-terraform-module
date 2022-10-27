### --- Common variables --- ###
variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs."
}

variable "number_of_az" {
  default     = "2"
  type        = string
  description = "Number of Availability zones."
}

variable "rds_security_group" {
  default = {}
  /*
  rds_security_group = {
    vpc_id        = "XXXXXXXXXXXXXXXXXXXXXX"
    ingress_rules = [{
      description = "Allow traffic to RDS. Managed by terraform."
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]

    egress_rules = [{
      description = "Outcoming traffic from RDS. Managed by terraform."
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]

    tags = {
      Name = "RDS-module-sg"
    }
  }
*/
  type        = any
  description = "A list of maps containing key/value pairs that define the rds security group to be created."
}

variable "aws_db_subnet_group_name" {
  default     = "rds-subnet-group-name"
  type        = string
  description = "The name of the DB subnet group."
}

variable "aws_db_subnet_group_tags" {
  default     = null
  type        = map(string)
  description = "Tags for the DB subnet group"
}

### --- Cluster variables --- ###
variable "rds_cluster_identifier" {
  default     = "trm-aurora-psql-cluster"
  type        = string
  description = "The cluster identifier."
}

variable "engine_version" {
  default     = "13.4"
  type        = string
  description = "Database engine version."
}

variable "db_name" {
  type        = string
  description = "DB name."
}

variable "roles_feature_names" {
  type        = map(string)
  description = "A map of ARNs for the IAM roles to associate to the RDS Cluster and name of the feature for association"
  default     = {}
}

variable "cluster_kms_key" {
  default     = null
  type        = string
  description = "The ARN for the KMS encryption key."
}

variable "cluster_storage_encrypted" {
  default     = false
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
}

variable "master_password_length" {
  description = "The length of the string desired."
  type        = number
  default     = 16
}

variable "master_password_special" {
  description = "Supply your own list of special characters to use for string generation."
  type        = string
  default     = "!#*()-_=[]{}<>:?"
}

variable "secretsmanager_password_secret_name" {
  type        = string
  description = "The name of the database password secret to retrieve from the AWS Secrets Manager."
}

variable "master_username" {
  default     = "postgres"
  type        = string
  description = "Username for the master DB user."
}

variable "skip_final_snapshot" {
  default     = "false"
  type        = string
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created."
}

variable "backup_retention_period" {
  default     = "1"
  type        = string
  description = "The backup retention period. Retention period must be between 1 and 35."
}

variable "preferred_backup_window" {
  default     = ""
  type        = string
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00."
}

variable "deletion_protection" {
  default     = "false"
  type        = string
  description = "The database can't be deleted when this value is set to true."
}

variable "cluster_cloudwatch_logs" {
  default     = ["postgresql"]
  type        = list(any)
  description = "Set of log types to export to cloudwatch. Types are supported: audit, error, general, slowquery, postgresql."
}

variable "vpc_security_group_ids" {
  default     = []
  type        = list(string)
  description = "List of VPC security groups to associate with the Cluster."
}

variable "rds_cluster_tags" {
  default     = null
  type        = map(string)
  description = "Tags for the aws_rds_cluster."
}

### ----- Cluster instance variables ---- ###
variable "cluster_instance_identifier" {
  type        = string
  description = "The identifier for the RDS cluster instance."
}

variable "instance_class" {
  default     = "db.r5.large"
  type        = string
  description = "The instance class to use."
}

variable "cluster_instance_number" {
  default     = "2"
  type        = string
  description = "Number of clister instance."
}

variable "cluster_instance_tags" {
  default     = null
  type        = map(string)
  description = "Tags for the aws rds cluster instances."
}

variable "cluster_instance_monitoring_role_arn" {
  default     = null
  type        = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
}

variable "cluster_instance_monitoring_interval" {
  default     = 0
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance."
}
### --- Parameter group variables --- ###
variable "parameters_group" {
  default     = null
  type        = any
  description = "Set of aws_rds_cluster_parameter_group options."
}
