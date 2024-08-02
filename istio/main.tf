resource "kubernetes_namespace" "istio-system" {
  metadata {
    annotations = {
      name = "istio-system"
    }
    labels = {
      name = "istio-system"
    }
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  version    = "1.22.3"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"

  namespace  = "istio-system"

  depends_on = [ kubernetes_namespace.istio-system ]
}

# resource "helm_release" "istio-cni" {
#   name       = "istio-cni"
#   version    = "1.22.3"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "cni"

#   namespace  = "istio-system"

#   depends_on = [ kubernetes_namespace.istio-system, helm_release.istio_base ]
# }


resource "helm_release" "istiod" {
  name       = "istiod"
  version    = "1.22.3"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"

  namespace  = "istio-system"

   set {
    name  = "values.global.istioNamespace"
    value = "istio-system"
  }

   set {
    name  = "pilot.cni.enabled"
    value = "true"
  }

  values = ["${file("./istio/istio-values.yaml")}"]
  depends_on = [ kubernetes_namespace.istio-system, helm_release.istio_base]
}

# resource "kubernetes_namespace" "istio-ingress" {
#   metadata {
#     annotations = {
#       name = "istio-ingress"
#     }
#     labels = {
#       name = "istio-ingress"
#       istio-injection = "enabled"
#     }
#     name = "istio-ingress"
#   }
# }

# resource "helm_release" "istio-ingressgateway" {
#   name       = "istio-ingressgateway"
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "gateway"


#   create_namespace = true
#   namespace        = "istio-ingress"

#   depends_on = [ helm_release.istio_base ]
# }
