resource "yandex_iam_service_account" "kube-infra" {
  depends_on = [ yandex_resourcemanager_folder.yc-deploy ]
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
  depends_on = [ yandex_resourcemanager_folder.yc-deploy ]
  labels = {
    environment = var.environment
  }

  master {
    version = "1.31"
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

resource "yandex_kubernetes_node_group" "group-1" {
  name       = "group-1"
  cluster_id = yandex_kubernetes_cluster.kube-infra.id
  version    = "1.31"
  labels = {
    environment = var.environment
  }

  instance_template {
    resources {
      cores  = 2
      memory = 4
    }

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.default-ru-central1-d.id]
      security_group_ids = [yandex_vpc_security_group.yc-security-group.id]
    }

    scheduling_policy {
      preemptible = true
    }

    metadata = {
      "ssh-keys" : "m1xxos:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      min     = 1
      max     = 2
    }
  }
}

data "yandex_client_config" "client" {}

data "yandex_kubernetes_cluster" "kube-infra" {
  name = yandex_kubernetes_cluster.kube-infra.name
}
