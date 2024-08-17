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

# resource "helm_release" "pg-secrets" {
#   name  = "pg-secrets"
#   chart = "./secrets/secrets"

#   namespace = kubernetes_namespace.psql-ns.metadata.0.name
# }


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

  set {
    name  = "primary.initdb.scripts.create_vector_extension\\.sh"
    value = <<EOF
  #!/bin/sh
  echo "Creating cve schema if it doesn't exist..."
  PGPASSWORD=${random_string.password.result} psql -U ${var.postgresUser} -d cve -c "CREATE SCHEMA IF NOT EXISTS cve;"
  echo "Creating vector extension in the cve schema of the PostgreSQL database..."
  PGPASSWORD=${random_string.password.result} psql -U postgres -d cve -c "CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA cve;"
  EOF
  }
}
