###############################################################################
# VPC Flow Logs → S3  (NO custom IAM role needed)
###############################################################################

# Allow Flow Logs service to write to the bucket
resource "aws_s3_bucket_policy" "allow_flowlogs" {
  bucket = aws_s3_bucket.log_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudTrail block already present …

      {
        Sid       = "AWSVPCFlowLogsWrite",
        Effect    = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.log_storage.arn}/vpc-flow-logs/*"
      }
    ]
  })
}

resource "aws_flow_log" "default_vpc" {
  vpc_id                   = data.aws_vpc.default.id
  log_destination_type     = "s3"
  log_destination          = aws_s3_bucket.log_storage.arn
  traffic_type             = "ALL"
  max_aggregation_interval = 60

  tags = {
    Project = "SplunkCloudSIEMLab"
    Source  = "VPC Flow Logs"
  }
}
