#!/bin/bash
# user_data.sh — install Splunk Enterprise, enable HEC, configure S3 input

# Download & extract Splunk
wget -O /tmp/splunk.tgz "https://download.splunk.com/products/splunk/releases/9.1.3/linux/splunk-9.1.3-xxxxxxx-linux-2.6-x86_64.tgz"
tar zxvf /tmp/splunk.tgz -C /opt

# Start Splunk, accept license, enable at boot
/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
/opt/splunk/bin/splunk enable boot-start

# Create HEC token (injected by Terraform)
/opt/splunk/bin/splunk http-event-collector create \
  --name terraform-hec \
  --token ${hec_token} \
  --index main

# Configure AWS S3 input for CloudTrail & VPC Flow Logs
/opt/splunk/bin/splunk add aws-account \
  --account-name terraform \
  --iam-role-arn arn:aws:iam::$(curl -s http://169.254.169.254/latest/meta-data/iam/info | jq -r .InstanceProfileArn) \
  --default

/opt/splunk/bin/splunk add s3-ltg \
  --bucket ${s3_bucket} \
  --sourcetype aws:cloudtrail

# Restart to pick up HEC & inputs
/opt/splunk/bin/splunk restart
