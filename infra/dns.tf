resource "yandex_cm_certificate" "kube-infra" {
  name    = "kube-infra"
  domains = ["*.${var.environment}-infra.m1xxos.me"]

  managed {
    challenge_type = "DNS_CNAME"
  }

  labels = {
    environment = var.environment
  }
  depends_on = [ yandex_resourcemanager_folder.yc-deploy ]
}

resource "cloudflare_record" "infra" {
  zone_id = var.cloudflare_zone_id
  name    = yandex_cm_certificate.kube-infra.domains[0]
  content = yandex_vpc_address.infra-alb.external_ipv4_address[0].address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "acme" {
  zone_id = var.cloudflare_zone_id
  name    = yandex_cm_certificate.kube-infra.challenges[0].dns_name
  type    = yandex_cm_certificate.kube-infra.challenges[0].dns_type
  content = yandex_cm_certificate.kube-infra.challenges[0].dns_value
  ttl     = 600
}