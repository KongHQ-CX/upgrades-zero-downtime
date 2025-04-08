resource "kubernetes_manifest" "ingress_alb" {
  manifest = yamldecode(templatefile("ingress-template.yaml",
  {
    service_name = var.kong_svc_name
  }))
}
