provider "aws" {
  region = var.region
}

resource "aws_s3_bucket_object" "etl_job_script" {
  bucket = replace(var.etl_script_s3_bucket, "s3://", "")
  key    = "glue_etl.py"
  source = "${path.module}/scripts/glue_etl.py"
  etag   = md5(file("${path.module}/scripts/glue_etl.py"))
}

resource "aws_glue_job" "cloudtrail_to_parquet" {
  name         = "CloudTrailToParquet"
  role_arn     = aws_iam_role.cloudtrail_parquet_glue.arn
  glue_version = "1.0"
  command {
    script_location = "${var.etl_script_s3_bucket}/glue_etl.py"
  }

  default_arguments = {
    "--TempDir"              = "${var.temp_s3_bucket}"
    "--glue_database"        = "${var.glue_database}"
    "--raw_cloudtrail_table" = "raw_${replace(replace(var.cloudtrail_s3_bucket, "s3://", ""), "-", "_")}"
    "--results_bucket"       = "${var.parquet_s3_bucket}"
    "--job-language"         = "python"
  }
}

resource "aws_glue_crawler" "cloudtrail_parquet_crawler" {
  database_name = var.glue_database
  classifiers   = []
  name          = "CloudTrailParquetCrawler"
  role          = aws_iam_role.cloudtrail_parquet_glue.arn
  table_prefix  = "cloudtrail_"
  s3_target {
    exclusions = []
    path       = "${var.parquet_s3_bucket}/parquet/"
  }

  configuration = jsonencode(
    {
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
        Tables = {
          AddOrUpdateBehavior = "MergeNewColumns"
        }
      }
      Version = 1
    }
  )
  schema_change_policy {
    delete_behavior = "DEPRECATE_IN_DATABASE"
    update_behavior = "LOG"
  }
}


resource "aws_glue_crawler" "cloudtrail_raw_crawler" {
  database_name = var.glue_database
  name          = "CloudTrailRawCrawler"
  role          = aws_iam_role.cloudtrail_parquet_glue.arn
  table_prefix  = "raw_"
  s3_target {
    path       = var.cloudtrail_s3_bucket
    exclusions = ["**-Digest**", "**Config**"]
  }

  configuration = jsonencode(
    {
      Version = "1.0",
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      },
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
      }
      Version = 1
    }
  )
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }
}

resource "aws_glue_trigger" "start_cloudtrail_raw_to_parquet" {
  name          = "StartCloudTrailRawToParquet"
  schedule      = "cron(10 12 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.cloudtrail_parquet_glue.name

  actions {
    crawler_name = "CloudTrailRawCrawler"
  }
}

resource "aws_glue_trigger" "after_cloudtrail_raw_crawler" {
  name          = "AfterCloudTrailRawCrawler"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.cloudtrail_parquet_glue.name

  actions {
    job_name = "CloudTrailToParquet"
  }

  predicate {
    logical = "ANY"

    conditions {
      crawl_state      = "SUCCEEDED"
      crawler_name     = "CloudTrailRawCrawler"
      logical_operator = "EQUALS"
    }
  }
}

resource "aws_glue_trigger" "after_cloudtrail_to_parquet" {
  name          = "AfterCloudTrailToParquet"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.cloudtrail_parquet_glue.name

  actions {
    crawler_name = "CloudTrailParquetCrawler"
  }
  predicate {
    logical = "ANY"
    conditions {
      job_name         = "CloudTrailToParquet"
      state            = "SUCCEEDED"
      logical_operator = "EQUALS"
    }
  }
}

resource "aws_glue_workflow" "cloudtrail_parquet_glue" {
  name = "CloudTrailParquetGlue"
}