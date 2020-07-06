data "aws_iam_policy_document" "cloudtrail_parquet_glue" {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "cloudtrail_parquet_glue" {
  name               = "CloudTrailParquetGlue"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_parquet_glue.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.cloudtrail_parquet_glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "read_cloudtrail_s3" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${replace(var.cloudtrail_s3_bucket, "s3://", "")}/*",
      "arn:aws:s3:::${replace(var.cloudtrail_s3_bucket, "s3://", "")}",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "read_cloudtrail_s3" {
  name        = "ReadCloudTrailS3"
  description = "Allow cloudtrail-parquet-glue to read from CloudTrail S3 bucket"
  policy      = data.aws_iam_policy_document.read_cloudtrail_s3.json
}

resource "aws_iam_role_policy_attachment" "read_cloudtrail_s3" {
  role       = aws_iam_role.cloudtrail_parquet_glue.name
  policy_arn = aws_iam_policy.read_cloudtrail_s3.arn
}

data "aws_iam_policy_document" "read_script_s3" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${replace(var.etl_script_s3_bucket, "s3://", "")}/*",
      "arn:aws:s3:::${replace(var.etl_script_s3_bucket, "s3://", "")}",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "read_script_s3" {
  name        = "ReadScriptS3"
  description = "Allow cloudtrail-parquet-glue to read from script S3 location"
  policy      = data.aws_iam_policy_document.read_script_s3.json
}

resource "aws_iam_role_policy_attachment" "read_script_s3" {
  role       = aws_iam_role.cloudtrail_parquet_glue.name
  policy_arn = aws_iam_policy.read_script_s3.arn
}

data "aws_iam_policy_document" "read_write_parquet_s3" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
     "arn:aws:s3:::${replace(var.parquet_s3_bucket, "s3://", "")}/*",
     "arn:aws:s3:::${replace(var.parquet_s3_bucket, "s3://", "")}",
     "arn:aws:s3:::${replace(var.temp_s3_bucket, "s3://", "")}/*",
     "arn:aws:s3:::${replace(var.temp_s3_bucket, "s3://", "")}",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "read_write_parquet_s3" {
  name        = "ReadWriteParquetS3"
  description = "Allow cloudtrail-parquet-glue to write to CloudTrail Parquet (and temp) S3 location"
  policy      = data.aws_iam_policy_document.read_write_parquet_s3.json
}

resource "aws_iam_role_policy_attachment" "read_write_parquet_s3" {
  role       = aws_iam_role.cloudtrail_parquet_glue.name
  policy_arn = aws_iam_policy.read_write_parquet_s3.arn
}