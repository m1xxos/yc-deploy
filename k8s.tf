resource "yandex_iam_service_account" "kube-infra" {
  name = "kube-infra"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = yandex_resourcemanager_folder.yc-deploy.id
  role      = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.kube-infra.id}"
  ]
}

resource "yandex_kubernetes_cluster" "kube-infra" {
  name       = "kube-infra"
  network_id = yandex_vpc_network.default.id
  master {
    version = "1.29"
    zonal {
      subnet_id = yandex_vpc_subnet.default-ru-central1-d.id
      zone      = yandex_vpc_subnet.default-ru-central1-d.zone
    }

    public_ip          = true
    security_group_ids = [yandex_vpc_security_group.yc-security-group.id]
  }

  service_account_id      = yandex_iam_service_account.kube-infra.id
  node_service_account_id = yandex_iam_service_account.kube-infra.id
  release_channel         = "RAPID"
}