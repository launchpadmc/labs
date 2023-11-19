variable "aws_region" {
  default     = "us-west-1"
  description = "aws region where our resources going to create choose"
}

variable "az_public" {
  default = ["us-west-1a", "us-west-1c"]
  #type = "list"
}

variable "az_private" {
  default = "us-west-1c"
}

variable "subnet_cidrs_public" {
  default = ["192.168.2.0/24", "192.168.0.0/24"]
}

variable "subnet_cidr_private" {
  default = "192.168.1.0/24"
}

variable "ssh_location" {
  type        = string
  description = "My Public IP Address"
  default     = "0.0.0.0/0"
}

variable "ami" {
  default = "ami-0cbd40f694b804622"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "subnet_rds" {
  default = ["192.168.3.0/24", "192.168.4.0/24"]

}
variable "az_rds" {
  default = ["us-west-1c", "us-west-1a"]
}

variable "subnet_cidrs" {
  default = ["192.168.3.0/24", "192.168.4.0/24", "192.168.2.0/24", "192.168.0.0/24", "192.168.1.0/24"]
}
