variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service" {
  description = "Service name (IAS, EAPI, LBS, CSSV2, MOCK)"
  type        = string
}

variable "version_label" {
  description = "Version label for the launch template"
  type        = string
}

variable "iac_version" {
  description = "Infrastructure as Code version"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "user_data_vars" {
  description = "Variables for user data script"
  type        = map(string)
}
