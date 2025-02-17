resource "yandex_cm_certificate" "kube-infra" {
  name    = "kube-infra"
  domains = ["*.infra.m1xxos.me"]

  managed {
    challenge_type = "DNS_CNAME"
  }
}

resource "cloudflare_record" "infra" {
  zone_id = var.cloudflare_zone_id
  name    = "*.infra.m1xxos.me"
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