provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "Owner"               = var.owner
      "Value_Stream"        = var.value_stream
      "Product"             = var.product
      "Component"           = var.component
      "Environment"         = var.environment
      "Data_Classification" = var.data_classification
      "Created_Using"       = var.created_using
      "Source_Code"         = var.source_code
    }
  }
}

############### Default provider variables block ################
variable "aws_region" {
  description = "The AWS region to use for provisioning"
  type        = string
}

# Default tags are described here
#https://vertexinc.atlassian.net/wiki/spaces/AWSTS/pages/2490108213/AWS+Objects+Tagging+Standards

variable "owner" {
  description = "The group that supports the environment."
  type        = string
}

variable "value_stream" {
  description = "The name of the Stream (e.g. Information Technology)."
  type        = string
}

variable "product" {
  description = "High level product that is sold to customers or used internally (e.g. Vertex Content Management System)."
  type        = string
}

variable "component" {
  description = "The name of the system components."
  type        = string
}

variable "environment" {
  description = "Specifies the current environment."
  type        = string
}

variable "data_classification" {
  description = "Type of data confidentiality."
  type        = string
}

variable "created_using" {
  description = "Tool that was used to create the application."
  type        = string
  default     = "Terraform"
}

variable "source_code" {
  description = "The location of the source code for creating this resource."
  type        = string
  default     = "trm-infra-rds"
}
