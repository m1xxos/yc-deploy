terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.3.1"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    key    = "ус-deploy.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }
}

provider "yandex" {
  zone      = "ru-central1-d"
  token     = var.token
  folder_id = var.folder_id
  cloud_id  = var.cloud_id
}

provider "kubernetes" {

  host                   = data.yandex_kubernetes_cluster.kube-infra.master.0.external_v4_endpoint
  cluster_ca_certificate = data.yandex_kubernetes_cluster.kube-infra.master.0.cluster_ca_certificate
  token                  = data.yandex_client_config.client.iam_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "helm" {
  kubernetes = {
    host                   = data.yandex_kubernetes_cluster.kube-infra.master.0.external_v4_endpoint
    cluster_ca_certificate = data.yandex_kubernetes_cluster.kube-infra.master.0.cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token
  }
}

provider "argocd" {
  port_forward = true
  username     = "admin"
  password     = var.argo_password
}