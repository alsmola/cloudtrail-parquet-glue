variable "region" {
  description = "AWS region for deploying Glue infrastructure"
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account for deploying Glue infrastructure"
  default     = "284971021687"
}

variable "cloudtrail_bucket" {
  type        = string
  description = "Bucket used for CloudTrail logs"
  default     = "aws-controltower-logs-284971021687-us-east-1"
}

variable "etl_script_bucket" {
  type        = string
  description = "Bucket used for script for Glue ETL job"
  default     = "azs-logs-release"
}

variable "etl_results_bucket" {
  type        = string
  description = "Bucket used for results of Glue ETL job"
  default     = "azs-logs-parquet"
}

variable "glue_service_role" {
  type        = string
  description = "Service IAM role name used for Glue job"
  default     = "AWSGlueServiceRoleDefault"
}

variable "glue_database" {
  type        = string
  description = "Glue database to use for CloudTrail crawler"
  default     = "cloudtrail"
}

variable "temp_directory" {
  type        = string
  description = "Bucket used for temporary files of Glue ETL job"
  default     = "azs-logs-temp"
}
