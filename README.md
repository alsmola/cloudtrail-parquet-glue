# cloudtrail-parquet-glue
`cloudtrail-parquet-glue` is terraform module that builds a Glue workflow to convert CloudTrail S3 logs to Athena-friendly Parquet format and make them available as a table using a Glue Crawler.


# What resources does cloudtrail-parquet-glue create?
![Glue workflow diagram](/diagram.png)

1. A Glue Crawler (`CloudTrailRawCrawler`) to build the raw CloudTrail logs table with partitions
1. A Glue ETL job (`CloudTrailToParquet`) to convert that table to Parquet format
1. A second Glue Crawler (`CloudTrailParquetCrawler`) to build the CloudTrail logs table with partitions

# How do I use cloudtrail-parquet-glue?
- Define the module and supply the information from your CloudTrail setup. You need to manually create three S3 buckets - one used for Glue ETL scripts (`etl_script_s3_bucket`), one used for temporary processing (`temp_s3_bucket`), and one used to store the parquet files (`parquet_s3_bucket`).

```
module "cloudtrail_parquet_glue" {
  source  = "github.com/alsmola/cloudtrail_parquet_glue"
  region = "us-east-1"
  aws_account_id  "1234567890"
  cloudtrail_s3_bucket = "s3://my-cloudtrail-bucket"
  etl_script_s3_bucket = "s3://my-etl-script-bucket"
  parquet_s3_bucket = "s3://my-parquet-bucket"
  temp_s3_bucket = = "s3://my-temp-bucket"
  glue_database = "cloudtrail"
}
```


- Workflow will be created to run daily, but you can run it manually to create the tables and partitions (`raw_[your_cloudtrailbucket_name]` and `cloudtrail_parquet`)