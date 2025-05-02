# log_bucket.tf
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "log_storage" {
  bucket        = "splunk-siem-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Project = "SplunkCloudSIEMLab"
    Purpose = "Store CloudTrail_VPC_Flow_Logs"   # no ampersand
  }
}
