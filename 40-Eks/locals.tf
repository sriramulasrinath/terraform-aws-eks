locals {
  vpc_id = data.aws_ssm_parameter.vpc_id
  private_subnet_ids = data.aws_ssm_parameter.private_subnet_ids.id 
  cluster_sg_id = data.aws_ssm_parameter.cluster_sg_id
  node_sg_id = data.aws_ssm_parameter.node_sg_id
}