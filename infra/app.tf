resource "kubernetes_manifest" "httpbin" {
  manifest = yamldecode(file("./manifests/deployment.yaml"))
}

resource "kubernetes_manifest" "httpbin-service" {
  manifest = yamldecode(file("./manifests/service.yaml"))
}