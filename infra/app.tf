resource "kubernetes_manifest" "httpbin" {
  manifest = yamldecode(file("./manifests/deployment.yaml"))
  depends_on = [ yandex_kubernetes_node_group.group-1 ]
}

resource "kubernetes_manifest" "httpbin-service" {
  manifest = yamldecode(file("./manifests/service.yaml"))
  depends_on = [ yandex_kubernetes_node_group.group-1 ]
}

resource "kubernetes_manifest" "httpbin-ingress" {
  manifest = yamldecode(<<EOT
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: httpbin
    namespace: httpbin
    annotations:
      ingress.alb.yc.io/subnets: ${yandex_vpc_subnet.default-ru-central1-d.id}
      ingress.alb.yc.io/external-ipv4-address: ${yandex_vpc_address.infra-alb.external_ipv4_address[0].address}
      ingress.alb.yc.io/group-name: infra-alb
      ingress.alb.yc.io/security-groups: ${yandex_vpc_security_group.yc-security-group.id}
  spec:
    tls:
      - hosts:
          - "httpbin.infra.m1xxos.me"
        secretName: yc-certmgr-cert-id-${yandex_cm_certificate.kube-infra.id}
    rules:
    - host: httpbin.infra.m1xxos.me
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: httpbin
              port:
                number: 80
  EOT
  )
  depends_on = [ yandex_kubernetes_node_group.group-1 ]
}