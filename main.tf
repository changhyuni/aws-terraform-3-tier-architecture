provider "aws" {
  region = "ap-northeast-2"
}


##################################################################
# VPC & Bastion Create
##################################################################
module "vpc" {
  source = "./modules/cheap_vpc"
  name = "spoon"
  cidr = "10.0.0.0/16"
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets   = ["10.0.0.0/23", "10.0.2.0/23"]
  private_subnets  = ["10.0.4.0/23", "10.0.6.0/23"]
  database_subnets = ["10.0.12.0/23", "10.0.14.0/23"]
  bastion_ami                 = data.aws_ami.amazon_linux_nat.id
  bastion_availability_zone   = module.vpc.azs[0]
  bastion_subnet_id           = module.vpc.public_subnets_ids[0]
  bastion_ingress_cidr_blocks = var.office_cidr_blocks
  bastion_keypair_name        = "changman"
  tags = {
    "project" = "spoon"
  }
}

##################################################################
# Security Groups
##################################################################

module "lb-security-public" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"
  name        = "lb-security-public"
  description = "elb"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = "false"
  ingress_with_cidr_blocks = [
    {
      from_port   = 443                                #인바운드 시작 포트
      to_port     = 443                                #인바운드 끝나는 포트
      protocol    = "tcp"                              #사용할 프로토콜
      description = "https"                            #설명
      cidr_blocks = "0.0.0.0/0"                        #허용할 IP 범위
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0                                #아웃바운드 시작 포트
      to_port     = 0                                #아웃바운드 끝나는 포트
      protocol    = "-1"                             #사용할 프로토콜
      description = "all"                            #설명
      cidr_blocks = "0.0.0.0/0"                      #허용할 IP 범위
    }
  ]
}
module "lb-security-private" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"
  name        = "lb-security-private"
  description = "elb"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = "false"
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
      source_security_group_id = module.autoscaler-public-security-group.this_security_group_id
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0                                #아웃바운드 시작 포트
      to_port     = 0                                #아웃바운드 끝나는 포트
      protocol    = "-1"                             #사용할 프로토콜
      description = "all"                            #설명
      cidr_blocks = "0.0.0.0/0"                      #허용할 IP 범위
    }
  ]
}
module "autoscaler-public-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"
  name        = "public-security-group"
  description = "public"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = "false"
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
      source_security_group_id = module.lb-security-public.this_security_group_id
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0                                #아웃바운드 시작 포트
      to_port     = 0                                #아웃바운드 끝나는 포트
      protocol    = "-1"                             #사용할 프로토콜
      description = "all"                            #설명
      cidr_blocks = "0.0.0.0/0"                      #허용할 IP 범위
    }
  ]
}
module "autoscaler-private-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"
  name        = "private-security-group"
  description = "public"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = "false"
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "web"
      cidr_blocks = "0.0.0.0/0"
      source_security_group_id = module.lb-security-private.this_security_group_id
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "tomcat"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0                                #아웃바운드 시작 포트
      to_port     = 0                                #아웃바운드 끝나는 포트
      protocol    = "-1"                             #사용할 프로토콜
      description = "all"                            #설명
      cidr_blocks = "0.0.0.0/0"                      #허용할 IP 범위
    }
  ]
}
module "database-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"
  name        = "rds"
  description = "database"
  vpc_id      = module.vpc.vpc_id
  use_name_prefix = "false"
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "rds"
      cidr_blocks = "0.0.0.0/0"
      source_security_group_id = module.lb-security-private.this_security_group_id
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0                                #아웃바운드 시작 포트
      to_port     = 0                                #아웃바운드 끝나는 포트
      protocol    = "-1"                             #사용할 프로토콜
      description = "all"                            #설명
      cidr_blocks = "0.0.0.0/0"                      #허용할 IP 범위
    }
  ]
}

##################################################################
# Web TierLoad Balancer
##################################################################
module "public-lb" {
  source  = "./modules/lb"
  name               = "public-load-balancer"
  internal           = false
  load_balancer_type = "application"
  vpc_id          = module.vpc.vpc_id
  security_groups = [module.lb-security-public.this_security_group_id, ]
  subnets         = module.vpc.public_subnets_ids
//
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]


  target_groups = [
    {
      name                 = "web-alb"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      vpc_id               = module.vpc.vpc_id
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-299"
      }
      tags = {
        InstanceTargetGroupTag = "nginx-webservers"
      }
    },
  ]

  tags = {
    Name = "Load Balancer"
  }

}
module "private-lb" {
  source  = "./modules/lb"
  name               = "private-load-balancer"
  internal           = true
  load_balancer_type = "application"
  vpc_id          = module.vpc.vpc_id
  security_groups = [module.lb-security-private.this_security_group_id]
  subnets         = module.vpc.private_subnets_ids
  //
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]


  target_groups = [
    {
      name                 = "application-alb"
      backend_protocol     = "HTTP"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      vpc_id               = module.vpc.vpc_id
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-299"
      }
      tags = {
        InstanceTargetGroupTag = "tomcat-application"
      }
    },
  ]

  tags = {
    Name = "Load Balancer"
  }

}

##################################################################
# Autosacle_group
##################################################################
module "autoscale-public-group" {
  source = "./modules/autoscale_group"
  environment = "web"
  name        = "public"
  image_id                    = "ami-05e11ae97b15e22be"
  instance_type               = "t3.small"
  security_group_ids          = [module.autoscaler-public-security-group.this_security_group_id]
  subnet_ids                  = module.vpc.public_subnets_ids
  health_check_type           = "ELB"
  min_size                    = 2
  max_size                    = 3
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = true
  key_name = "changman"
  target_group_arns = module.public-lb.target_group_arns

  tags = {
    Name              = "Public-autoscaler"
    Tier              = "Web"
  }
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}
module "autoscale-private-group" {
  source = "./modules/autoscale_group"
  environment = "aplication"
  name        = "private"
  image_id                    = "ami-0f79ebcc002d12eb4"
  instance_type               = "t3.small"
  security_group_ids          = [module.autoscaler-private-security-group.this_security_group_id]
  subnet_ids                  = module.vpc.private_subnets_ids
  health_check_type           = "ELB"
  min_size                    = 2
  max_size                    = 3
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = false
  key_name = "changman"
  target_group_arns = module.private-lb.target_group_arns
  tags = {
    Name              = "Private-autoscaler"
    Tier              = "Application"
  }
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}

##################################################################
# RDS Database tier
##################################################################
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"
  identifier = "demodb"
  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.large"
  allocated_storage = 5
  name     = "demodb"
  username = "loanshark"
  password = "kchksh1961"
  port     = "3306"
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [module.database-security-group.this_security_group_id]
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = module.vpc.database_subnets_ids

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}