module "postgres_chart" {
  source                = "./postgres"
  postgresUser          = var.postgresUser
  region                = var.region
  eks_cluster_name      = module.eks.cluster_name
  eks_instance_role_arn = aws_iam_role.eks_instance_role.arn
}

module "kafka_chart" {
  source                     = "./kafka"
  eks_cluster_name           = module.eks.cluster_name
  serviceMonitoringNamespace = var.serviceMonitorNamespace
}

module "cve-operator_chart" {
  source           = "./cve-operator"
  eks_cluster_name = module.eks.cluster_name
  dockerCreds      = var.dockerCreds
}

module "node-autoscaler_chart" {
  source            = "./node-autoscaler"
  region            = var.region
  eks_cluster_name  = module.eks.cluster_name
  eks_oidc_provider = module.eks.oidc_provider
  depends_on        = [module.eks]
}

module "fluent-bit_chart" {
  source            = "./fluent-bit"
  region            = var.region
  eks_cluster_name  = module.eks.cluster_name
  eks_oidc_provider = module.eks.oidc_provider
  depends_on        = [module.eks]
}

module "cve-consumer_chart" {
  source           = "./cve-consumer"
  eks_cluster_name = module.eks.cluster_name
  dockerCreds      = var.dockerCreds
  postgresPassword = module.postgres_chart.postgresPassword
  postgresUser     = var.postgresUser
  depends_on       = [module.eks, module.postgres_chart]
}

module "namespace-config" {
  source                = "./namespace-config"
  postgresUser          = var.postgresUser
  region                = var.region
  eks_cluster_name      = module.eks.cluster_name
  eks_oidc_provider     = module.eks.oidc_provider
  eks_instance_role_arn = aws_iam_role.eks_instance_role.arn
  dockerCreds           = var.dockerCreds
  kafka_def_req_cpu     = var.kafka_def_req_cpu
  kafka_def_req_mem     = var.kafka_def_req_mem
  kafka_def_lim_cpu     = var.kafka_def_lim_cpu
  kafka_def_lim_mem     = var.kafka_def_lim_mem
  cont_def_req_cpu      = var.cont_def_req_cpu
  cont_def_req_mem      = var.cont_def_req_mem
  cont_def_lim_cpu      = var.cont_def_lim_cpu
  cont_def_lim_mem      = var.cont_def_lim_mem
  depends_on            = [module.eks, module.postgres_chart, module.kafka_chart]
}
