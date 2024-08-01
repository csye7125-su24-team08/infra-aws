resource "helm_release" "kafka" {
  depends_on = [var.eks_cluster_name]

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "29.3.4"
  name       = "webapp-kafka"

  create_namespace = true
  namespace        = "kafka-ns"

  values = ["${file("./kafka/kafka-values.yaml")}"]

  set {
    name  = "replicaCount"
    value = "3"
  }

  set {
    name  = "metrics.serviceMonitor.namespace"
    value = var.serviceMonitoringNamespace
  }

}
