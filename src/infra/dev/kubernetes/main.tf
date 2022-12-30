module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_desired_size = var.cluster_desired_size
  cluster_min_size     = var.cluster_min_size
  cluser_max_size      = var.cluser_max_size

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  node_disk_size         = var.node_disk_size
  instance_types         = var.instance_types
  instance_capacity_type = var.instance_capacity_type

  label = module.label
}
