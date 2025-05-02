# Architecture Overview

1. **Central Logging S3 Bucket**  
   – Bucket: `splunk-siem-logs-<ACCOUNT_ID>`  
   – Stores CloudTrail (`AWSLogs/...`) and VPC Flow Logs (`vpc-flow-logs/...`)

2. **CloudTrail**  
   – Multi-region trail pointing to the bucket  
   – File-validation enabled

3. **VPC Flow Logs**  
   – ALL traffic, 60-second interval  
   – Delivered to the same bucket prefix

4. **Splunk EC2 (next)**  
   – Security group opens 22/8000/8088  
   – User-data bootstraps HEC endpoint



Splunk Cloud SIEM Lab Architecture

This document outlines the high-level design and component interactions of the Splunk Cloud SIEM Lab deployed via Terraform.

Components

Central S3 Log Bucket (splunk-siem-logs-<ACCOUNT_ID>)

Receives all CloudTrail event logs and VPC Flow Logs.

Configured with bucket policy allowing trusted AWS services to write logs.

CloudTrail Multi-Region Trail

Captures management and data events across all regions.

Writes compressed JSON archives to S3:/AWSLogs/<AccountID>/CloudTrail/

VPC Flow Logs

Streams VPC network flow data (ALL traffic) to the same central bucket under vpc-flow-logs/.

Aggregation interval: 60 seconds.

Terraform Workspace

terraform/ folder contains all infrastructure code (versions.tf, provider.tf, resource files).

Profiles:

admin – full-permission user for one-off IAM cleanup tasks.

terraform-admin – least-privilege user that runs the Terraform apply.

soclab – AWS CLI profile bound to terraform-admin credentials.

(Planned) Splunk Enterprise on EC2

EC2 instance provisioned via Terraform with user_data bootstrap for HEC.

Security group opens ports 22, 8000 (Splunk Web), 8088 (HEC).

Splunk Add-on for AWS configured to pull from the S3 prefixes.

Data Flow Diagram

              ┌────────────────────┐
              │  AWS CloudTrail    │
              │ (multi-region)     │
              └─────────┬──────────┘
                        │
                        │ Write
                        ▼
        ┌────────────────────────────────────┐
        │   S3 Bucket: splunk-siem-logs-###  │
        │  ┌──────────────────────────────┐  │
        │  │ AWSLogs/<Acct>/CloudTrail/   │  │
        │  └──────────────────────────────┘  │
        │  ┌──────────────────────────────┐  │
        │  │ vpc-flow-logs/               │  │
        │  └──────────────────────────────┘  │
        └─────────────────┬──────────────────┘
                          │
                          │ Ingest via Splunk Add-on
                          ▼
                    ┌────────────┐
                    │ Splunk EC2 │
                    │  (HEC)     │
                    └────────────┘

Next Steps

Launch Splunk Enterprise EC2 via Terraform

Configure S3 inputs in Splunk for both prefixes

Deploy initial Sigma/SPL detections and dashboards