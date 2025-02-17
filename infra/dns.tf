resource "cloudflare_record" "infra" {
  zone_id = var.cloudflare_zone_id
  name    = "*.infra.m1xxos.me"
  content = yandex_vpc_address.infra-alb.external_ipv4_address[0].address
  type    = "A"
  ttl     = 300
}