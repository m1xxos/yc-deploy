resource "kubernetes_namespace" "argocd" {
  metadata {
    labels = {
      name = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "oci://cr.yandex/yc-marketplace/yandex-cloud/argo/chart/"
  chart            = "argo-cd"
  create_namespace = true
  version          = "7.3.11-2"
  values           = [file("./manifests/argocd.yaml")]
  wait             = true

  depends_on = [ yandex_kubernetes_node_group.group-1 ]
}

resource "kubernetes_secret" "helm-secrets-private-keys" {
  metadata {
    name      = "helm-secrets-private-keys"
    namespace = "argocd"
  }
  data = {
    "key.txt" = file("./key.txt")
  }

  depends_on = [ yandex_kubernetes_node_group.group-1, kubernetes_namespace.argocd ]
}

resource "argocd_application" "app_of_apps" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "apps"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url = "https://github.com/m1xxos/yc-deploy.git"
      path     = "/argo-apps/charts/apps"

      helm {
        value_files = ["/argo-apps/values/apps.yaml"]
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }

    sync_policy {
      automated {
        prune     = false
        self_heal = true
      }
    }
  }
}