resource "kubernetes_limit_range" "kafka_ns_limit_range" {
  metadata {
    name      = "kafka-ns-limit-range"
    namespace = "kafka-ns"
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "600m"
        memory = "900Mi"
      }
      default_request = {
        cpu    = "300m"
        memory = "300Mi"
      }
    }
  }

  depends_on = [helm_release.kafka]
}
