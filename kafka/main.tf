resource "kubernetes_namespace" "kafka-ns" {
  metadata {
    annotations = {
      name = "kafka-ns"
    }
    labels = {
      name = "kafka-ns"
      istio-injection = "enabled"
    }
    name = "kafka-ns"
  }
}

resource "helm_release" "kafka" {
  depends_on = [ kubernetes_namespace.kafka-ns ]
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "kafka"
  version    = "29.3.4"
  name       = "webapp-kafka"

  # create_namespace = true
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
