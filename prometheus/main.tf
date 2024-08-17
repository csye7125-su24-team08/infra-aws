resource "helm_release" "prometheus" {
  name       = "prometheus"
  version    = "61.6.1"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  create_namespace = true
  namespace        = var.serviceMonitoringNamespace
}

# resource "helm_release" "grafana-gateway" {
#   name      = "grafana-gateway"
#   chart     = "./grafana-gateway/Chart.yaml"
#   namespace = var.serviceMonitoringNamespace
# }
