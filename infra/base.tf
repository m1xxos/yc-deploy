resource "yandex_resourcemanager_folder" "yc-deploy" {
  name        = "${var.environment}-yc-deploy"
  description = "yc deploy course resources"
  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_vpc_network" "default" {
  name = "default"
  labels = {
    environment = var.environment
  }
  depends_on = [ yandex_resourcemanager_folder.yc-deploy ]
}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  name           = "default-ru-central1-a"
  v4_cidr_blocks = ["10.127.0.0/24"]
  network_id     = yandex_vpc_network.default.id
  zone           = "ru-central1-a"
  labels = {
    environment = var.environment
  }
}

resource "yandex_vpc_subnet" "default-ru-central1-b" {
  name           = "default-ru-central1-b"
  v4_cidr_blocks = ["10.128.0.0/24"]
  network_id     = yandex_vpc_network.default.id
  zone           = "ru-central1-b"
  labels = {
    environment = var.environment
  }
}

resource "yandex_vpc_subnet" "default-ru-central1-d" {
  name           = "default-ru-central1-d"
  v4_cidr_blocks = ["10.129.0.0/24"]
  network_id     = yandex_vpc_network.default.id
  zone           = "ru-central1-d"
  labels = {
    environment = var.environment
  }
}

resource "yandex_vpc_security_group" "yc-security-group" {
  name        = "yc-security-group"
  description = "yc deploy sg"
  network_id  = yandex_vpc_network.default.id

  labels = {
    environment = var.environment
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["10.96.0.0/16", "10.112.0.0/16"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }
}

resource "yandex_vpc_address" "infra-alb" {
  name = "infra-alb"
  depends_on = [ yandex_resourcemanager_folder.yc-deploy ]
  labels = {
    "reserved"  = true
    environment = var.environment
  }

  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
}
