resource "aws_ssm_parameter" "db_sg_id" {
  name  = "/${var.project_name}/${var.environment}/db_sg_id"
  type  = "String"
  value = module.db.sg_id
}
# resource "aws_ssm_parameter" "backend_sg_id" {
#   name  = "/${var.project_name}/${var.environment}/backend_sg_id"
#   type  = "String"
#   value = module.backend.sg_id
# }
# resource "aws_ssm_parameter" "frontend_sg_id" {
#   name  = "/${var.project_name}/${var.environment}/frontend_sg_id"
#   type  = "String"
#   value = module.frontend.sg_id
# }
resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project_name}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion.sg_id
}
resource "aws_ssm_parameter" "vpn_sg_id" {
  name  = "/${var.project_name}/${var.environment}/vpn_sg_id"
  type  = "String"
  value = module.vpn.sg_id
}
# resource "aws_ssm_parameter" "app_alb_sg_id" {
#   name  = "/${var.project_name}/${var.environment}/app_alb_sg_id"
#   type  = "String"
#   value = module.app_alb.sg_id
# }
# resource "aws_ssm_parameter" "web_alb_sg_id" {
#   name  = "/${var.project_name}/${var.environment}/web_alb_sg_id"
#   type  = "String"
#   value = module.web_alb.sg_id
# }
resource "aws_ssm_parameter" "ingress_sg_id" {
  name  = "/${var.project_name}/${var.environment}/ingress_sg_id"
  type  = "String"
  value = module.ingress.sg_id
}

resource "aws_ssm_parameter" "cluster_sg_id" {
  name  = "/${var.project_name}/${var.environment}/cluster_sg_id"
  type  = "String"
  value = module.cluster.sg_id
}
resource "aws_ssm_parameter" "node_sg_id" {
  name  = "/${var.project_name}/${var.environment}/node_sg_id"
  type  = "String"
  value = module.node.sg_id
}