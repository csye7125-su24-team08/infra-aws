# helm install \
# cert-manager jetstack/cert-manager \
# --namespace cert-manager \
# --create-namespace \
# --version v1.15.3 \
# --set crds.enabled=true


resource "helm_release" "cert-manager" {

  name             = "cert-manager"
  chart            = "jetstack/cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.15.3"
  set {
    name  = "crds.enabled"
    value = "true"
  }

}

resource "helm_release" "cert-manager-certificate" {
  name             = "cert-manager-certificate"
  chart            = "./cert-manager/cert-manager"
  namespace        = "cert-manager"

  depends_on = [helm_release.cert-manager]

}
