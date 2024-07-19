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

resource "kubernetes_namespace" "cve_processor_ns" {
  metadata {
    annotations = {
      name = "cve-processor"
    }
    labels = {
      name = "cve-processor"
    }
    name = "cve-processor"
  }

  depends_on = [ helm_release.kafka ]
}

resource "kubernetes_limit_range" "cve_processor_limit_range" {
  metadata {
    name      = "cve-processor-limit-range"
    namespace = "cve-processor"
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "200m"
        memory = "300Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "200Mi"
      }
    }
  }

  depends_on = [kubernetes_namespace.cve_processor_ns]
}

resource "kubernetes_limit_range" "cve_consumer_limit_range" {
  metadata {
    name      = "cve-consumer-limit-range"
    namespace = "cve-consumer"
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "200m"
        memory = "300Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "200Mi"
      }
    }
  }

  depends_on = [helm_release.postgresql]
}
