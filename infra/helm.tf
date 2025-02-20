resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "oci://cr.yandex/yc-marketplace/yandex-cloud/argo/chart/"
  chart            = "argo-cd"
  create_namespace = true
  version          = "7.3.11-2"
  values           = [file("./manifests/argocd.yaml.dec")]
}

resource "kubernetes_secret" "helm-secrets-private-keys" {
  metadata {
    name = "helm-secrets-private-keys"
    namespace = "argocd"
  }
  data = {
    "key.txt" = file("./key.txt")
  }
}