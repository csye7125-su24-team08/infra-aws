resource "random_string" "password" {
  length  = 12
  special = false
}

resource "kubernetes_namespace" "psql-ns" {
  metadata {
    annotations = {
      name = "psql-ns"
    }
    labels = {
      name = "psql-ns"
    }
    name = "psql-ns"
  }
}

resource "helm_release" "postgresql" {
  depends_on = [kubernetes_namespace.psql-ns]
  name       = "webapp-postgresql"
  version    = "15.5.6"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"

  namespace = "psql-ns"

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
