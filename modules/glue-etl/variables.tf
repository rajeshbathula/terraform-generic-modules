variable "project" {
  description = "project ex: twitter-feeds or facebook-posts"
  type        = string
}

variable "environment" {
  description = "dev or prod or preprod"
  type        = string
}

variable "common_tags" {
  description = "used to audit billing "
  type        = map(string)
}

variable "app_name" {
  description = "layer or app name"
  type        = string
}

variable "bucket_name_src" {
  description = "bucket that have objects that needed to convert"
  type        = string
}

variable "bucket_name_dst" {
  description = "bucket that used to put converted objets"
  type        = string
}

variable "script_bucket_name" {
  description = "bucket that used to put scripts"
  type        = string
  default     = ""
}

variable "job_bookmark_option" {
  description = "Keeps history of objects that got processed so it can read only new objects"
  type        = string
  default     = "job-bookmark-enable"
}

variable "local_script_path" {
  description = "directory where glue script is"
  type        = string
}

variable "script_object_name" {
  description = "name of the script"
  type        = string
  default     = "main.py"
}

variable "script_helper_object_name" {
  description = "additional python files that required for the job"
  type        = string
}

variable "etl_schedule" {
  description = "aws cron to schedule your job"
  type        = string
  default     = ""
}

variable "glue_job_allocated_capacity" {
  description = "Data Processing Units -- cost and perfomance related"
  default     = 2
}

variable "glue_job_type" {
  description = ""
  type        = string
  default     = "ON_DEMAND"
}