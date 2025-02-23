resource "yandex_iam_service_account" "ingress-controller" {
  name = "ingress-controller"
}

resource "yandex_resourcemanager_folder_iam_binding" "alb-editor" {
  folder_id = yandex_resourcemanager_folder.yc-deploy.id
  role      = "alb.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.ingress-controller.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-publicAdmin" {
  folder_id = yandex_resourcemanager_folder.yc-deploy.id
  role      = "vpc.publicAdmin"

  members = [
    "serviceAccount:${yandex_iam_service_account.ingress-controller.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "certificates-downloader" {
  folder_id = yandex_resourcemanager_folder.yc-deploy.id
  role      = "certificate-manager.certificates.downloader"

  members = [
    "serviceAccount:${yandex_iam_service_account.ingress-controller.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "compute-viewer" {
  folder_id = yandex_resourcemanager_folder.yc-deploy.id
  role      = "compute.viewer"

  members = [
    "serviceAccount:${yandex_iam_service_account.ingress-controller.id}"
  ]
}

resource "yandex_kubernetes_marketplace_helm_release" "alb" {
  cluster_id = yandex_kubernetes_cluster.kube-infra.id

  product_version = "f2e1jkau91ivrj60555s"
  name = "yc-alb-ingress-controller-chart"
  namespace = "yc-alb-ingress"

  user_values = {
    folderId = yandex_resourcemanager_folder.yc-deploy.id
    clusterId = yandex_kubernetes_cluster.kube-infra.id
    saKeySecretKey = file("../sa-key.json")
  }
}