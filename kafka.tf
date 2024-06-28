resource "helm_release" "kafka" {
  depends_on = [module.eks]

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "29.3.4"
  name       = "webapp-kafka"

  create_namespace = true
  namespace = "kafka-ns"

  values           = ["${file("kafka-values.yaml")}"]

  set {
    name  = "replicaCount"
    value = "3"
  }

}
