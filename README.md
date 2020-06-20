# cloudtrail-parquet-glue
Glue workflow to convert CloudTrail logs to Athena-friendly Parquet format

- Glue Crawler to build the raw CloudTrail logs table with partitions
- Glue ETL job to convert that table to Parquet format
- A second Glue Crawler to build the CloudTrail logs table with partitions
