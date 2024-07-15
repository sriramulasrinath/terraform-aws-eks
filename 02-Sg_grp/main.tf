module "db" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for DB MYSQL Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "Db"
}

module "ingress" {
  source = "git::https://github.com/sriramulasrinath/terraform-aws-security-grp.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for ingress controller"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "ingress"
}
module "cluster" {
  source = "git::https://github.com/sriramulasrinath/terraform-aws-security-grp.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for EKS control plane"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "eks-control-plane"
}
module "node" {
  source = "git::https://github.com/sriramulasrinath/terraform-aws-security-grp.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for EKS nodes"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "node"
}

module "backend" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for backend Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "backend"
}
module "frontend" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG frontend Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "frontend"
}

module "bastion" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for bastion Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "bastion"
}
module "app_alb" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for app_alb Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "app_alb"
}
module "web_alb" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for web_alb Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "web_alb"
}
module "vpn" {
  source = "../../Terraform-SG-module"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for vpn Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags 
  sg_name = "vpn"
  ingress_rules = var.vpn_sg_rules
}
##############################################################
##                DATABASE
##############################################################
# Db is accepting connections from backend
resource "aws_security_group_rule" "db-backend" {
  type              = "ingress"
  from_port         =3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id #where you are getting traffic from
  security_group_id = module.db.sg_id
}
### Db is accepting connections from bastion
resource "aws_security_group_rule" "db-bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id#where you are getting traffic from
  security_group_id = module.db.sg_id
}
### Db is accepting connections from vpn
resource "aws_security_group_rule" "db-vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id#where you are getting traffic from
  security_group_id = module.vpn.sg_id
}
###############################################################
###       BACKEND
#################################################################
### backend is accepting connections from bastion
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id #where you are getting traffic from
  security_group_id = module.backend.sg_id
}
### backend is accepting connections from vpn_ssh
resource "aws_security_group_rule" "backend_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id #where you are getting traffic from
  security_group_id = module.backend.sg_id
}
### backend is accepting connections from vpn_http
resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id #where you are getting traffic from
  security_group_id = module.backend.sg_id
}
### backend is accepting connections from app_alb
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb.sg_id #where you are getting traffic from
  security_group_id = module.backend.sg_id
}
###############################################################
###       APP_ALB
#################################################################
### app_alb is accepting connections from vpn
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id #where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}
resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id #where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}
resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.app_alb.sg_id
}
###############################################################
###       WEB-ALB
#################################################################
resource "aws_security_group_rule" "web_alb_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # source is where you are getting traffic from
  security_group_id = module.web_alb.sg_id
}
resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # source is where you are getting traffic from
  security_group_id = module.web_alb.sg_id
}
###############################################################
###       FRONTEND
#################################################################
resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks =  ["0.0.0.0/0"]#where you are getting traffic from
  security_group_id = module.frontend.sg_id
}
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id#where you are getting traffic from
  security_group_id = module.frontend.sg_id
}
resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id = module.frontend.sg_id
}
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb.sg_id 
  security_group_id = module.frontend.sg_id
}
###############################################################
###       BASTION
#################################################################
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks =  ["0.0.0.0/0"]#where you are getting traffic from
  security_group_id = module.bastion.sg_id
}
###############################################################
###       FOR CICD TOOLS
#################################################################
resource "aws_security_group_rule" "backend_default_vpc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks =  ["172.31.0.0/16"]#where you are getting traffic from
  security_group_id = module.backend.sg_id
}
resource "aws_security_group_rule" "frontend_default_vpc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks =  ["172.31.0.0/16"]#where you are getting traffic from
  security_group_id = module.frontend.sg_id
}
###############################################################
###       Control Plane (EKS)
#################################################################

resource "aws_security_group_rule" "cluster_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = module.node_sg_id#where you are getting traffic from
  security_group_id = module.cluster.sg_id
}
resource "aws_security_group_rule" "node_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = module.cluster_sg_id#where you are getting traffic from
  security_group_id = module.node.sg_id
}
resource "aws_security_group_rule" "node_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = module.ingress_sg_id#where you are getting traffic from
  security_group_id = module.node.sg_id
}
resource "aws_security_group_rule" "db_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = module.node_sg_id#where you are getting traffic from
  security_group_id = module.db.sg_id
}
resource "aws_security_group_rule" "ingress_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]#where you are getting traffic from
  security_group_id = module.ingress.sg_id
}