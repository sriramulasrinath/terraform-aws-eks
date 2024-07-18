resource "aws_key_name" "eks" {
  key_name = eks 
  #publuc_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTOBOBCPGetwFG2ik3sR9lqg59BmRvyY9ljrXuLDJEi"
  public_key = file("~/.ssh/eks.pub")
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.30"

  # it should be false in PROD environments
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids) # Eks nodes should not expose in public subnet ids
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id



  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      min_size     = 2
      max_size     = 10
      desired_size = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
         AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
         AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
       }
       # EKS takes AWS Linux 2 as it's OS to the nodes
       key_name = aws_key_pair.eks.key_name
    }

    # green = {
    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #      AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #      AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #    }
    # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
  }
  tags = var.common_tags
}

resource "aws_autoscaling_policy" "blue" {
  name                   = "${var.project_name}-${var.environment}-blue-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = module.eks.eks_managed_node_groups["blue"].resources.autoscaling_groups[0]

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70
  }
  
}