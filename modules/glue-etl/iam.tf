resource "aws_iam_role" "glue_iam" {
  name = "${local.job_name}_glue_iam_role"
  tags   = var.common_tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue_iam.id
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "my_s3_policy" {
  name = "${local.job_name}_policy_access_s3"
  role = aws_iam_role.glue_iam.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
              "s3:ListBucket",
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.script_bucket_name}",
        "arn:aws:s3:::${local.script_bucket_name}/*",
        "arn:aws:s3:::${local.bucket_name_src}",
        "arn:aws:s3:::${local.bucket_name_src}/*",
        "arn:aws:s3:::${local.bucket_name_dst}",
        "arn:aws:s3:::${local.bucket_name_dst}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "glue_service_s3" {
    name = "${local.job_name}_glue_policy_access_s3"
    role = aws_iam_role.glue_iam.id
    policy = aws_iam_role_policy.my_s3_policy.policy
}
