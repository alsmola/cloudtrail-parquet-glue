# cloudtrail-parquet-glue
Glue workflow to convert CloudTrail logs to Athena-friendly Parquet format

- Glue Crawler to build the raw CloudTrail logs table with partitions
- Glue ETL job to convert that table to Parquet format
- A second Glue Crawler to build the CloudTrail logs table with partitions

To use
------
- Update the vars.tf file with your AWS Glue and S3 configuration values
- Ensure the Glue IAM role has read access to CloudTrail and script S3 locations and read/write access to the temporary directory S3 location
- Workflow will be created to run daily