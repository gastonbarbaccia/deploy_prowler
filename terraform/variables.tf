variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "instance_disk_size" {
  default = 30
}



variable "ec2_name" {
  default = "prowler_dev"
}

variable "sg_name_ec2" {
  default = "sg_prowler_dev"
}


variable "key_pair_name" {
  default = "security"
}


variable "private_key_file" {
  type = string
}
