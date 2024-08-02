resource "random_string" "password" {
  length  = 12
  special = false
}

resource "kubernetes_namespace" "cve-consumer" {
  metadata {
    annotations = {
      name = "cve-consumer"
    }
    labels = {
      name = "cve-consumer"
      istio-injection = "enabled"
    }
    name = "cve-consumer"
  }
}

resource "helm_release" "postgresql" {
  depends_on = [var.eks_cluster_name, kubernetes_namespace.cve-consumer]
  name       = "webapp-postgresql"
  version    = "15.5.6"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"

  # create_namespace = true
  namespace        = "cve-consumer"

  values = ["${file("./postgres/postgres-values.yaml")}"]

  set {
    name  = "auth.username"
    value = var.postgresUser
  }

  set {
    name  = "auth.password"
    value = random_string.password.result
  }

  set {
    name  = "auth.postgresPassword"
    value = random_string.password.result
  }

  set {
    name  = "metrics.prometheusRule.namespace"
    value = var.serviceMonitorNamespace
  }
}
