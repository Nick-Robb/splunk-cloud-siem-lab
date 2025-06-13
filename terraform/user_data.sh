#!/bin/bash
# user_data.sh — install Splunk Enterprise, enable HEC, configure S3 input

# Download & extract Splunk
wget -O /tmp/splunk.tgz "https://download.splunk.com/products/splunk/releases/9.1.3/linux/splunk-9.1.3-xxxxxxx-linux-2.6-x86_64.tgz"
tar zxvf /tmp/splunk.tgz -C /opt

# Enable Splunk at boot and accept license
/opt/splunk/bin/splunk enable boot-start --accept-license --answer-yes

# Only seed the admin password if this is the very first setup
if [ ! -f /opt/splunk/etc/passwd ]; then
    /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd "changeme"
else
    /opt/splunk/bin/splunk start
fi

# Wait for Splunk to be fully started before config (important!)
sleep 40

# Create HEC token (injected by Terraform)
if [ ! -z "${hec_token}" ]; then
  /opt/splunk/bin/splunk http-event-collector create \
    --name terraform-hec \
    --token ${hec_token} \
    --index main
fi

# Configure AWS S3 input for CloudTrail & VPC Flow Logs (optional, requires Splunk add-ons)
if [ ! -z "${s3_bucket}" ]; then
  /opt/splunk/bin/splunk add aws-account \
    --account-name terraform \
    --iam-role-arn arn:aws:iam::$(curl -s http://169.254.169.254/latest/meta-data/iam/info | jq -r .InstanceProfileArn) \
    --default

  /opt/splunk/bin/splunk add s3-ltg \
    --bucket ${s3_bucket} \
    --sourcetype aws:cloudtrail
fi

# Final restart to apply all settings
/opt/splunk/bin/splunk restart
