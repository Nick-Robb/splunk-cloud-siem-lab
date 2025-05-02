###############################################################################
# CloudTrail: records every API call in your AWS account and writes them
#             to the S3 bucket you just created.
###############################################################################

# Allow CloudTrail to write into the bucket
resource "aws_s3_bucket_policy" "allow_cloudtrail" {
  bucket = aws_s3_bucket.log_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.log_storage.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.log_storage.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# Create the CloudTrail trail
resource "aws_cloudtrail" "main" {
  name                          = "splunk-siem-trail"
  s3_bucket_name                = aws_s3_bucket.log_storage.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true      # integrity hashes
  include_global_service_events = true
  depends_on                    = [aws_s3_bucket_policy.allow_cloudtrail]
}
