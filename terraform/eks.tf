module "eks" {

  for_each = toset(var.clusters[*].name)
  source   = "terraform-aws-modules/eks/aws"
  version  = "18.26.6"

  cluster_name    = each.key
  cluster_version = "1.22"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    attach_cluster_primary_security_group = true
    disk_size                             = "160"
    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types         = ["t3a.2xlarge"]
      create_launch_template = false
      launch_template_name   = ""

      disk_size = 50

      min_size     = 2
      max_size     = 5
      desired_size = 3

      pre_bootstrap_user_data = <<-EOT
      echo 'foo bar'
      EOT

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }


  }
}
