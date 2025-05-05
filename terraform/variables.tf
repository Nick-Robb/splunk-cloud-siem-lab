variable "splunk_ami_id" {
  description = "The AMI ID for Splunk Enterprise in us‑east‑1"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access Splunk (SSH, Web, HEC)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type for Splunk"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
