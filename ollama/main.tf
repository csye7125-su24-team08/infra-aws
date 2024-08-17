resource "helm_release" "ollama" {

  name             = "ollama"
  chart            = "./ollama/ollama"
  namespace        = "ollama"
  create_namespace = true

}
