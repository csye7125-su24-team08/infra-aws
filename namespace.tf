resource "kubernetes_limit_range" "kafka_ns_limit_range" {
  metadata {
    name      = "kafka-ns-limit-range"
    namespace = "kafka-ns"
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.kafka_def_lim_cpu
        memory = var.kafka_def_lim_mem
      }
      default_request = {
        cpu    = var.kafka_def_req_cpu
        memory = var.kafka_def_req_mem
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

  depends_on = [helm_release.kafka]
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
        cpu    = var.cont_def_lim_cpu
        memory = var.cont_def_lim_mem
      }
      default_request = {
        cpu    = var.cont_def_req_cpu
        memory = var.cont_def_req_mem
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
        cpu    = var.cont_def_lim_cpu
        memory = var.cont_def_lim_mem
      }
      default_request = {
        cpu    = var.cont_def_req_cpu
        memory = var.cont_def_req_mem
      }
    }
  }

  depends_on = [helm_release.postgresql]
}
