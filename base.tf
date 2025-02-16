resource "yandex_resourcemanager_folder" "yc-deploy" {
    name = "yc-deploy"
    description = "yc deploy course resources"
}

resource "yandex_vpc_network" "default" {
  name = "default"
}