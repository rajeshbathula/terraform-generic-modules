locals {
  job_name                 = "${replace(var.project, "-", "_")}_${var.environment}_${replace(var.app_name, "-", "_")}"
  project_prefix           = "${replace(var.project, "-", "_")}_${var.environment}"
  glue_job_name            = "${replace(local.job_name, "-", "_")}"
  tempdirectory_etl        = "${var.app_name}_file_log"
  bucket_name_src          = var.bucket_name_src
  bucket_name_dst          = var.bucket_name_dst
  bucket_script_prefix     = "${var.app_name}/script"
  bucket_script_object     = "${var.script_object_name}"
  script_bucket_name       = var.script_bucket_name ? var.script_bucket_name : aws_s3_bucket.glue_etl_script.bucket
}

resource "aws_s3_bucket" "glue_etl_script" {
  count  = var.script_bucket_name ? 1 : 0
  bucket = "${local.project_prefix}-glue-scripts"
  acl    = "private"
  tags   = var.common_tags
}

# cloudwatch LOGS not loggin into the below path
resource "aws_cloudwatch_log_group" "glue_etl_log" {
  name              = "/aws-glue/jobs/${local.glue_job_name}"
  retention_in_days = 14
}

resource "aws_s3_bucket_object" "etl_script_key" {
  depends_on = [aws_s3_bucket.glue_etl_script]
  bucket     = aws_s3_bucket.glue_etl_script.bucket
  key        = "${local.bucket_script_prefix}/${var.script_object_name}"
  source     = "${var.local_script_path}/${var.script_object_name}"
  tags       = var.common_tags

  etag = filemd5("${var.local_script_path}/${var.script_object_name}")
}


resource "aws_s3_bucket_object" "etl_script_helper_object" {
  depends_on = [aws_s3_bucket.glue_etl_script]
  bucket     = aws_s3_bucket.glue_etl_script.bucket
  key        = "${local.bucket_script_prefix}/${var.script_helper_object_name}"
  source     = "${var.local_script_path}/${var.script_helper_object_name}"
  tags       = var.common_tags

  etag       = filemd5("${var.local_script_path}/${var.script_helper_object_name}")
}

resource "aws_glue_job" "glue_etl_job" {
  depends_on   = [aws_s3_bucket.glue_etl_script]
  name         = local.job_name
  max_capacity = var.glue_job_allocated_capacity
  role_arn     = aws_iam_role.glue_iam.arn
  glue_version = "1.0"
  tags         = var.common_tags
  command {
    python_version  = 3
    script_location = "s3://${local.script_bucket_name}/${local.bucket_script_prefix}/${var.script_helper_object_name}"
  }
  default_arguments = {
    "--src_bucket_name"                  = local.bucket_name_src
    "--parquet_bucket_name"              = local.bucket_name_dst
    "--enable-continuous-cloudwatch-log" = true
    "--job-bookmark-option"              = var.job_bookmark_option
    "--TempDir"                          = "s3://${local.script_bucket_name}/${local.tempdirectory_etl}"
    "--extra-py-files"                   = "s3://${local.script_bucket_name}/${local.bucket_script_prefix}/${var.script_helper_object_name}"
  }
}

resource "aws_glue_trigger" "2parquet_scheduled" {
  count    = var.glue_job_type == "SCHEDULED" ? 1 : 0
  name     = "${local.glue_job_name}_trigger"
  schedule = var.etl_schedule
  type     = var.glue_job_type
  tags     = var.common_tags
  actions {
    job_name = aws_glue_job.glue_etl_job.name
  }
}

resource "aws_glue_trigger" "2parquet_ondemand" {
  count = var.glue_job_type == "ON_DEMAND" ? 1 : 0
  name = "${local.glue_job_name}_trigger"
  type = var.glue_job_type
  tags = var.common_tags
  actions {
    job_name = aws_glue_job.glue_etl_job.name
  }
}