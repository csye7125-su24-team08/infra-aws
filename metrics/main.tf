resource "helm_release" "metrics" {
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  name       = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

}
