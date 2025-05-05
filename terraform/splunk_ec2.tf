# Security Group for SSH, Splunk Web, and HEC
resource "aws_security_group" "splunk_sg" {
  name        = "splunk-sg"
  description = "Allow SSH, Splunk Web, and HEC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "SplunkCloudSIEMLab"
    Source  = "EC2 Security Group"
  }
}

# Generate a random HEC token
resource "random_string" "hec_token" {
  length  = 16
  special = false
}

# SSH keypair for Splunk
resource "aws_key_pair" "splunk_key" {
  key_name   = "splunk-key"
  public_key = file(var.public_key_path)
}

# Splunk EC2 instance
resource "aws_instance" "splunk" {
  ami                    = var.splunk_ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.splunk_key.key_name
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
  subnet_id = data.aws_subnets.default.ids[0]

  user_data = templatefile("${path.module}/user_data.sh", {
    hec_token = random_string.hec_token.result
    s3_bucket = aws_s3_bucket.log_storage.bucket
  })

  tags = {
    Name    = "splunk-instance"
    Project = "SplunkCloudSIEMLab"
  }
}

# Outputs
output "splunk_public_ip" {
  description = "Public IP of the Splunk EC2 instance"
  value       = aws_instance.splunk.public_ip
}

output "splunk_web_url" {
  description = "URL to access Splunk Web interface"
  value       = "http://${aws_instance.splunk.public_ip}:8000"
}

output "splunk_hec_token" {
  description = "HTTP Event Collector token for Splunk"
  value       = random_string.hec_token.result
}
