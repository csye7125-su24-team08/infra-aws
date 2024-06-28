resource "random_string" "password" {
  length  = 12
  special = false
}

resource "helm_release" "postgresql" {
  depends_on = [module.eks]
  name       = "webapp-postgresql"
  version    = "15.5.6"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"


  create_namespace = true
  namespace        = "cve-consumer"

  values = ["${file("postgres-values.yaml")}"]

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
}
