data "aws_ami" "amazon_linux_nat" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

variable "office_cidr_blocks" {
  type = "list"

  default = [
    "0.0.0.0/0",
  ]
}

variable "keypair_name" {
  default = "changman"
}


