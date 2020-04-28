**This will provision GLUE ETL JOB, as part of this modiule will take care of iam permission and required policy's to access data buckets and creating bucket for script if you havent specified one and trigger if you give a cron and option it to schedule or it will go as ON_DEMAND **

**EXAMPLE REFER LINK**
WORKINGGGG!!

NOT COVERED: Script -- which can be PYTHON or SCALA both uses Spark, you have to come up with script depending on requirement and formats that you considering converting from and into

module "app1-glue-etl" {
  source                      =  "git@github.com:rajeshbathula/terraform-generic-modules.git//modules/glue_etl?ref=<TAG-VERSION>"
  project                     =  "project-name"
  app_name                    =  "application-name-this"
  environment                 =  "${var.environment}"
  common_tags                 =  "${var.tags}"
  bucket_name_src             =  "src_bucket_s3"
  bucket_name_dst             =  "dest_bucket_s3"
  script_bucket_name          =  "dpp-${var.aws_role}-framework-infrastructure"
  local_script_path           =  "../../../apps/glue-lettuce-know/jglue/"
  script_object_name          =  "main.py"
  script_helper_object_name   =  "data_quality_checks.json"
  glue_job_allocated_capacity =  "2"
  glue_job_type               =  "SCHEDULED"
  etl_schedule                =  "cron(00 09 * * ? *)"
}