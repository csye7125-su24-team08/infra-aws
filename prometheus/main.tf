resource "helm_release" "prometheus" {
  name       = "prometheus"
  version    = "61.6.1"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  # values = ["${file("./prometheus/values.yaml")}"]

  create_namespace = true
  namespace        = var.serviceMonitoringNamespace
}
