import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME", "glue_database", "raw_cloudtrail_table", "results_bucket", "TempDir"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = args["glue_database"], table_name = args["raw_cloudtrail_table"], transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("eventversion", "string", "eventversion", "string"), ("useridentity", "struct", "useridentity", "struct"), ("eventtime", "string", "eventtime", "string"), ("eventsource", "string", "eventsource", "string"), ("eventname", "string", "eventname", "string"), ("awsregion", "string", "awsregion", "string"), ("sourceipaddress", "string", "sourceipaddress", "string"), ("useragent", "string", "useragent", "string"), ("requestparameters", "struct", "requestparameters", "string"), ("responseelements", "struct", "responseelements", "string"), ("requestid", "string", "requestid", "string"), ("eventid", "string", "eventid", "string"), ("eventtype", "string", "eventtype", "string"), ("recipientaccountid", "string", "recipientaccountid", "string"), ("resources", "array", "resources", "array"), ("sharedeventid", "string", "sharedeventid", "string"), ("errorcode", "string", "errorcode", "string"), ("errormessage", "string", "errormessage", "string"), ("apiversion", "string", "apiversion", "string"), ("readonly", "boolean", "readonly", "boolean"), ("additionaleventdata", "struct", "additionaleventdata", "string"), ("vpcendpointid", "string", "vpcendpointid", "string"), ("managementevent", "boolean", "managementevent", "boolean"), ("eventcategory", "string", "eventcategory", "string"), ("serviceeventdetails", "struct", "serviceeventdetails", "struct"), ("partition_0", "string", "awslogs", "string"), ("partition_1", "string", "account", "string"), ("partition_2", "string", "cloudtrail", "string"), ("partition_3", "string", "region", "string"), ("partition_4", "string", "year", "string"), ("partition_5", "string", "month", "string"), ("partition_6", "string", "day", "string")], transformation_ctx = "applymapping1")
resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")
relationalized3 = resolvechoice2.relationalize("trail", args["TempDir"]).select("trail")
datasink4 = glueContext.write_dynamic_frame.from_options(frame = relationalized3, connection_type = "s3", connection_options = {"path": args["results_bucket"] + "/parquet", "partitionKeys": ["account", "region", "year", "month", "day"]}, format = "parquet", transformation_ctx = "datasink4")
job.commit()