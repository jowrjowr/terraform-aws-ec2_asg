variable "environment" {
  description = "environment name"
  default     = "dev"
  type        = string
}

variable "project" {
  description = "project tag"
  type        = string
}

variable "name" {
  description = "allows for additional sub-project naming"
  default     = "main"
  type        = string
}

variable "ec2_ami" {
  description = "AMI id for the instance to use"
  type        = string
}

variable "account_id" {
  description = "primary AWS account ID"
  type        = number
}

variable "ec2_instance_type" {
  description = "instance type"
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "ssh key name"
  default     = ""
  type        = string
}

variable "ec2_user_data" {
  description = "the *BASE 64 ENCODED* user_data blob"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "how big the root volume is in gb"
  default     = 20
  type        = number
}

variable "ec2_public_ip" {
  description = "whether to associate an ipv4 public ip"
  default     = true
  type        = bool
}

variable "ec2_additional_security_groups" {
  description = "what additional security group ids to attach to the instance"
  default     = []
  type        = list(string)
}

variable "ec2_policies" {
  description = "a map of name:json policies that will be attached to the instance role"
  default     = {}
  type        = map
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
}

variable "asg_subnets" {
  description = "the list of subnets the ASG can start within"
  type        = list(string)
}

variable "asg_target_groups" {
  description = "a list of load balancer target group ARNs to attach to the ASG"
  default     = []
  type        = list(string)
}

variable "asg_health_check_type" {
  description = "what kind of health check will be done"
  default     = "ELB"
  type        = string
}

variable "db_username" {
  description = "IAM RDS database username"
  default     = "placeholder"
  type        = string
}
